// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

protocol TransactionFlowInteractable: Interactable,
    EnterAmountPageListener,
    ConfirmationPageListener,
    AccountPickerListener,
    PendingTransactionPageListener,
    TargetSelectionPageListener
{

    var router: TransactionFlowRouting? { get set }
    var listener: TransactionFlowListener? { get set }

    func didSelectSourceAccount(account: BlockchainAccount)
    func didSelectDestinationAccount(target: TransactionTarget)
}

public protocol TransactionFlowViewControllable: ViewControllable {
    func present(viewController: ViewControllable?, animated: Bool)
    func replaceRoot(viewController: ViewControllable?, animated: Bool)
    func push(viewController: ViewControllable?)
    func dismiss()
    func pop()
}

typealias TransactionViewableRouter = ViewableRouter<TransactionFlowInteractable, TransactionFlowViewControllable>

final class TransactionFlowRouter: TransactionViewableRouter, TransactionFlowRouting {

    private let alertViewPresenter: AlertViewPresenterAPI
    private let topMostViewControllerProvider: TopMostViewControllerProviding
    private let disposeBag = DisposeBag()
    private var linkBankFlowRouter: LinkBankFlowStarter?

    var isDisplayingRootViewController: Bool {
        viewController.uiviewController.presentedViewController == nil
    }

    init(
        interactor: TransactionFlowInteractable,
        viewController: TransactionFlowViewControllable,
        topMostViewControllerProvider: TopMostViewControllerProviding = resolve(),
        alertViewPresenter: AlertViewPresenterAPI = resolve()
    ) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        self.alertViewPresenter = alertViewPresenter
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    func routeToConfirmation(transactionModel: TransactionModel) {
        let builder = ConfirmationPageBuilder(transactionModel: transactionModel)
        let router = builder.build(listener: interactor)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func routeToInProgress(transactionModel: TransactionModel, action: AssetAction) {
        let builder = PendingTransactionPageBuilder()
        let router = builder.build(
            withListener: interactor,
            transactionModel: transactionModel,
            action: action
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.push(viewController: viewControllable)
    }

    func closeFlow() {
        viewController.dismiss()
        interactor.listener?.dismissTransactionFlow()
    }

    func showFailure(error: Error) {
        Logger.shared.error(error)
        alertViewPresenter.error(in: viewController.uiviewController) { [weak self] in
            self?.closeFlow()
        }
    }

    func pop() {
        viewController.pop()
    }

    func dismiss() {
        guard let top = topMostViewControllerProvider.topMostViewController else {
            return
        }
        guard let child = children.last else { return }
        top.dismiss(animated: true, completion: nil)
        detachChild(child)
    }

    func didTapBack() {
        guard let child = children.last else { return }
        pop()
        detachChild(child)
    }

    func routeToSourceAccountPicker(transactionModel: TransactionModel, action: AssetAction) {
        showSourceAccountPicker(transactionModel: transactionModel, action: action)
    }

    func showSourceAccountPicker(transactionModel: TransactionModel, action: AssetAction) {
        let router = sourceAccountPickerRouter(with: transactionModel, action: action)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable, animated: false)
    }

    func presentSourceAccountPicker(transactionModel: TransactionModel, action: AssetAction) {
        let router = sourceAccountPickerRouter(with: transactionModel, action: action)
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.present(viewController: viewControllable, animated: true)
    }

    func showDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction) {
        let router = destinationAccountPicker(
            with: transactionModel,
            navigationModel: ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            ),
            action: action
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable, animated: false)
    }

    func presentDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction) {
        let router = destinationAccountPicker(
            with: transactionModel,
            navigationModel: ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            ),
            action: action
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.present(viewController: viewControllable, animated: true)
    }

    func routeToDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction) {
        let shouldPush = action != .buy
        let navigationModel: ScreenNavigationModel
        if shouldPush {
            navigationModel = ScreenNavigationModel.AccountPicker.navigationClose(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            )
        } else {
            navigationModel = ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.destinationTitle(action: action)
            )
        }

        let router = destinationAccountPicker(
            with: transactionModel,
            navigationModel: navigationModel,
            action: action
        )
        let viewControllable = router.viewControllable
        attachChild(router)

        if shouldPush {
            viewController.push(viewController: viewControllable)
        } else {
            viewController.replaceRoot(viewController: viewControllable, animated: false)
        }
    }

    func routeToTargetSelectionPicker(transactionModel: TransactionModel, action: AssetAction) {
        let builder = TargetSelectionPageBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: { $0.availableTargets as? [BlockchainAccount] ?? [] }
            ),
            action: action
        )
        let router = builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.TargetSelection.navigation(
                title: TransactionFlowDescriptor.TargetSelection.navigationTitle(action: action)
            ),
            backButtonInterceptor: {
                transactionModel.state.map {
                    ($0.step, $0.stepsBackStack, $0.isGoingBack)
                }
            }
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        viewController.replaceRoot(viewController: viewControllable, animated: false)
    }

    func presentLinkABank(transactionModel: TransactionModel) {
        let builder = LinkBankFlowRootBuilder()
        let router = builder.build()
        linkBankFlowRouter = router
        router.startFlow()
            .withLatestFrom(transactionModel.state) { ($0, $1) }
            .subscribe(onNext: { [topMostViewControllerProvider] effect, state in
                switch effect {
                case .closeFlow:
                    topMostViewControllerProvider
                        .topMostViewController?
                        .dismiss(animated: true, completion: nil)
                    transactionModel.process(action: .bankLinkingFlowDismissed(state.action))
                case .bankLinked:
                    if let source = state.source {
                        transactionModel.process(action: .bankAccountLinkedFromSource(source, state.action))
                    } else {
                        transactionModel.process(action: .bankAccountLinked(state.action))
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func routeToPriceInput(
        source: BlockchainAccount,
        destination: TransactionTarget,
        transactionModel: TransactionModel,
        action: AssetAction
    ) {
        guard let source = source as? SingleAccount else { return }
        let builder = EnterAmountPageBuilder(transactionModel: transactionModel)
        let router = builder.build(
            listener: interactor,
            sourceAccount: source,
            destinationAccount: destination,
            action: action,
            navigationModel: ScreenNavigationModel.EnterAmount.navigation(
                allowsBackButton: action.allowsBackButton
            )
        )
        let viewControllable = router.viewControllable
        attachChild(router)
        if let childVC = viewController.uiviewController.children.first,
           childVC is TransactionFlowInitialViewController
        {
            viewController.replaceRoot(viewController: viewControllable, animated: false)
        } else {
            viewController.push(viewController: viewControllable)
        }
    }

    func presentKYCFlowIfNeeded(completion: @escaping (Bool) -> Void) {
        let presenter = topMostViewControllerProvider.topMostViewController ?? viewController.uiviewController
        interactor.listener?.presentKYCFlowIfNeeded(from: presenter, completion: completion)
    }

    // MARK: - Private Functions

    private func sourceAccountPickerRouter(
        with transactionModel: TransactionModel,
        action: AssetAction
    ) -> AccountPickerRouting {
        let subtitle = TransactionFlowDescriptor.AccountPicker.sourceSubtitle(action: action)
        let builder = AccountPickerBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: { $0.availableSources }
            ),
            action: action
        )
        let button: ButtonViewModel? = action == .deposit ? .secondary(with: LocalizationConstants.addNew) : nil
        return builder.build(
            listener: .listener(interactor),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(
                title: TransactionFlowDescriptor.AccountPicker.sourceTitle(action: action)
            ),
            headerModel: subtitle.isEmpty ? .none : .simple(AccountPickerSimpleHeaderModel(subtitle: subtitle)),
            buttonViewModel: button
        )
    }

    private func destinationAccountPicker(
        with transactionModel: TransactionModel,
        navigationModel: ScreenNavigationModel,
        action: AssetAction
    ) -> AccountPickerRouting {
        let subtitle = TransactionFlowDescriptor.AccountPicker.destinationSubtitle(action: action)
        let builder = AccountPickerBuilder(
            accountProvider: TransactionModelAccountProvider(
                transactionModel: transactionModel,
                transform: {
                    $0.availableTargets as? [BlockchainAccount] ?? []
                }
            ),
            action: action
        )
        let button: ButtonViewModel? = action == .withdraw ? .secondary(with: LocalizationConstants.addNew) : nil
        return builder.build(
            listener: .listener(interactor),
            navigationModel: navigationModel,
            headerModel: subtitle.isEmpty ? .none : .simple(AccountPickerSimpleHeaderModel(subtitle: subtitle)),
            buttonViewModel: button
        )
    }
}
