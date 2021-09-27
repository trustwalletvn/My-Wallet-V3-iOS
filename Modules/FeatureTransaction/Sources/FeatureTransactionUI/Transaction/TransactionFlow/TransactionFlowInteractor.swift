// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxRelay
import RxSwift
import ToolKit

protocol TransactionFlowRouting: Routing {

    var isDisplayingRootViewController: Bool { get }

    /// Pop the current screen off the stack.
    func pop()

    /// Dismiss the top most screen. Currently not called but should be used when
    /// a picker is presented over the `Enter Amount` screen. This is different from
    /// going back.
    func dismiss()

    /// Exit the flow. This occurs usually when the user taps the close button
    /// on the top right of the screen.
    func closeFlow()

    /// Show the failure screen. Sometimes an error is thrown when selecting an
    /// account or entering in transaction details. If this error occurs, we should
    /// show a failure screen.
    func showFailure(error: Error)

    /// The back button was tapped.
    func didTapBack()

    /// Show the `source` selection screen. This replaces the root.
    func routeToSourceAccountPicker(transactionModel: TransactionModel, action: AssetAction)

    /// Present the destination account picker modally over the current screen
    func presentSourceAccountPicker(transactionModel: TransactionModel, action: AssetAction)

    /// Show the target selection screen (currently only used in `Send`).
    /// This pushes onto the prior screen.
    func routeToTargetSelectionPicker(transactionModel: TransactionModel, action: AssetAction)

    /// Show the destination account picker without routing from a prior screen
    func showDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction)

    /// Route to the destination account picker from the target selection screen
    func routeToDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction)

    /// Present the destination account picker modally over the current screen
    func presentDestinationAccountPicker(transactionModel: TransactionModel, action: AssetAction)

    /// Present the bank linking flow modally over the current screen
    func presentLinkABank(transactionModel: TransactionModel)

    /// Route to the in progress screen. This pushes onto the navigation stack.
    func routeToInProgress(transactionModel: TransactionModel, action: AssetAction)

    /// Show the `EnterAmount` screen. This pushes onto the prior screen.
    /// For `Buy` we should set this as the root.
    func routeToPriceInput(
        source: BlockchainAccount,
        destination: TransactionTarget,
        transactionModel: TransactionModel,
        action: AssetAction
    )

    /// Show the confirmation screen. This pushes onto the prior screen.
    func routeToConfirmation(transactionModel: TransactionModel)

    /// Presents the KYC Flow if needed or progresses the transactionModel to the next step otherwise
    func presentKYCFlowIfNeeded(completion: @escaping (Bool) -> Void)
}

protocol TransactionFlowListener: AnyObject {
    func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void)
    func dismissTransactionFlow()
}

final class TransactionFlowInteractor: PresentableInteractor<TransactionFlowPresentable>,
    TransactionFlowInteractable,
    AccountPickerListener,
    TransactionFlowPresentableListener,
    TargetSelectionPageListener
{

    weak var router: TransactionFlowRouting?
    weak var listener: TransactionFlowListener?

    private var initialStep: Bool = true
    private let transactionModel: TransactionModel
    private let action: AssetAction // TODO: this should be removed and taken from TransactionModel
    private let sourceAccount: BlockchainAccount? // TODO: this should be removed and taken from TransactionModel
    private let target: TransactionTarget? // TODO: this should be removed and taken from TransactionModel
    private let analyticsHook: TransactionAnalyticsHook

    init(
        transactionModel: TransactionModel,
        action: AssetAction,
        sourceAccount: BlockchainAccount?,
        target: TransactionTarget?,
        presenter: TransactionFlowPresentable,
        analyticsHook: TransactionAnalyticsHook = resolve()
    ) {
        self.transactionModel = transactionModel
        self.action = action
        self.sourceAccount = sourceAccount
        self.target = target
        self.analyticsHook = analyticsHook
        super.init(presenter: presenter)
        presenter.listener = self
    }

    deinit {
        transactionModel.destroy()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        transactionModel
            .state
            .do(onNext: { state in
                #if DEBUG
                print("[\(TransactionFlowInteractor.self)] State changed:")
                dump(state, maxDepth: 1)
                #endif
            })
            .distinctUntilChanged(\.step)
            .withPrevious()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe { [weak self] previousState, newState in
                self?.handleStateChange(previousState: previousState, newState: newState)
            }
            .disposeOnDeactivate(interactor: self)

        let requireSecondPassword: Single<Bool> = sourceAccount?.requireSecondPassword ?? .just(false)

        requireSecondPassword
            .observeOn(MainScheduler.asyncInstance)
            .map { [sourceAccount, target, action] passwordRequired -> TransactionAction in
                switch action {
                case .deposit:
                    return self.handleFiatDeposit(
                        sourceAccount: sourceAccount,
                        target: target,
                        passwordRequired: passwordRequired
                    )

                case .swap where sourceAccount != nil && target != nil:
                    return .initialiseWithSourceAndPreferredTarget(
                        action: action,
                        sourceAccount: sourceAccount!,
                        target: target!,
                        passwordRequired: passwordRequired
                    )

                case _ where sourceAccount != nil && target != nil:
                    return .initialiseWithSourceAndTargetAccount(
                        action: action,
                        sourceAccount: sourceAccount!,
                        target: target!,
                        passwordRequired: passwordRequired
                    )

                case _ where sourceAccount != nil:
                    return .initialiseWithSourceAccount(
                        action: action,
                        sourceAccount: sourceAccount!,
                        passwordRequired: passwordRequired
                    )

                case _ where target != nil:
                    return .initialiseWithTargetAndNoSource(
                        action: action,
                        target: target!,
                        passwordRequired: passwordRequired
                    )

                default:
                    return .initialiseWithNoSourceOrTargetAccount(
                        action: action,
                        passwordRequired: passwordRequired
                    )
                }
            }
            .subscribe(
                onSuccess: { [weak self] action in
                    self?.transactionModel.process(action: action)
                },
                onError: { [weak self] error in
                    Logger.shared.debug("Unable to configure transaction flow, aborting. \(String(describing: error))")
                    self?.finishFlow()
                }
            )
            .disposeOnDeactivate(interactor: self)
    }

    override func willResignActive() {
        super.willResignActive()
    }

    func didSelectActionButton() {
        transactionModel.process(action: .showBankLinkingFlow)
    }

    func didSelect(blockchainAccount: BlockchainAccount) {
        guard let target = blockchainAccount as? TransactionTarget else {
            fatalError("Account \(blockchainAccount.self) is not currently supported.")
        }
        didSelect(target: target)
    }

    func didSelect(target: TransactionTarget) {
        transactionModel.state
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { [weak self] state in
                switch state.step {
                case .selectSource:
                    /// Apply the source account
                    self?.didSelectSourceAccount(account: target as! BlockchainAccount)
                    /// If the flow was started with a destination already, like if they
                    /// are depositing into a `FiatAccount`, we apply the destination.
                    /// This will route the user to the `Enter Amount` screen.
                    if let destination = state.destination {
                        self?.didSelectDestinationAccount(target: destination)
                    }
                case .selectTarget:
                    self?.didSelectDestinationAccount(target: target)
                    if let selectedSource = state.source as? CryptoAccount,
                       let target = target as? CryptoAccount
                    {
                        self?.analyticsHook.onReceiveAccountSelected(
                            selectedSource,
                            target: target,
                            action: state.action
                        )
                    }

                default:
                    break
                }
            })
            .disposeOnDeactivate(interactor: self)
    }

    func didTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func didTapClose() {
        guard router?.isDisplayingRootViewController == true else {
            // there's a modal to dismiss
            transactionModel.process(action: .returnToPreviousStep)
            return
        }
        // the top most view controller is at the root of the flow, so dismissing it means closing the flow itself.
        router?.closeFlow()
        analyticsHook.onClose(action: action)
    }

    func enterAmountDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func closeFlow() {
        transactionModel.process(action: .resetFlow)
        router?.closeFlow()
        analyticsHook.onClose(action: action)
    }

    func checkoutDidTapBack() {
        transactionModel.process(action: .returnToPreviousStep)
    }

    func didSelectSourceAccount(account: BlockchainAccount) {
        analyticsHook.onFromAccountSelected(account, action: action)
        transactionModel.process(action: .sourceAccountSelected(account))
    }

    func didSelectDestinationAccount(target: TransactionTarget) {
        transactionModel.process(action: .targetAccountSelected(target))
    }

    func didConfirmTransaction() {
        transactionModel.process(action: .executeTransaction)
    }

    func continueToKYCTiersScreen() {
        router?.presentKYCFlowIfNeeded { _ in
            // NOOP: this was designed for Swap where presenting KYC means replacing the root view with a KYC prompt.
            // This completion block is never called.
        }
    }

    func showGenericFailure(error: Error) {
        router?.showFailure(error: error)
    }

    // MARK: - Private Functions

    private func doCloseFlow() {
        router?.closeFlow()
        analyticsHook.onClose(action: action)
    }

    private func handleStateChange(previousState: TransactionState?, newState: TransactionState) {
        if !initialStep, newState.step == .initial {
            finishFlow()
        } else {
            initialStep = newState.step == .initial
            showFlowStep(previousState: previousState, newState: newState)
            analyticsHook.onStepChanged(newState)
        }
    }

    private func finishFlow() {
        transactionModel.process(action: .resetFlow)
    }

    private func showFlowStep(previousState: TransactionState?, newState: TransactionState) {
        guard !newState.isGoingBack else {
            guard previousState?.step != .kycChecks else {
                // KYC gets dismissed automatically
                return
            }

            if router?.isDisplayingRootViewController == false {
                router?.dismiss()
            } else {
                router?.didTapBack()
            }
            return
        }

        switch newState.step {
        case .initial:
            break

        case .enterAmount:
            router?.routeToPriceInput(
                source: newState.source!,
                destination: newState.destination!,
                transactionModel: transactionModel,
                action: action
            )

        case .linkABank:
            router?.presentLinkABank(transactionModel: transactionModel)

        case .enterPassword:
            unimplemented()

        case .selectTarget:
            /// `TargetSelectionViewController` should only be shown for `SendP2`
            /// and `.send`. Otherwise we should show the account picker to select
            /// the destination/target.
            switch action {
            case .send:
                // `Send` supports the target selection screen rather than a
                // destination selection screen.
                router?.routeToTargetSelectionPicker(
                    transactionModel: transactionModel,
                    action: action
                )
            case .buy:
                if newState.stepsBackStack.contains(.enterAmount) {
                    router?.presentDestinationAccountPicker(
                        transactionModel: transactionModel,
                        action: action
                    )
                } else {
                    router?.routeToDestinationAccountPicker(
                        transactionModel: transactionModel,
                        action: action
                    )
                }
            case .withdraw:
                // `Withdraw` shows the destination screen modally. It does not
                // present over another screen (and thus replaces the root).
                router?.showDestinationAccountPicker(
                    transactionModel: transactionModel,
                    action: action
                )
            case .viewActivity,
                 .deposit,
                 .sell,
                 .receive,
                 .swap:
                // This pushes on the destination screen.
                router?.routeToDestinationAccountPicker(
                    transactionModel: transactionModel,
                    action: action
                )
            }

        case .kycChecks:
            router?.presentKYCFlowIfNeeded { [transactionModel] didCompleteKYC in
                if didCompleteKYC {
                    transactionModel.process(action: .prepareTransaction)
                } else {
                    transactionModel.process(action: .returnToPreviousStep)
                }
            }

        case .confirmDetail:
            router?.routeToConfirmation(transactionModel: transactionModel)

        case .inProgress:
            router?.routeToInProgress(
                transactionModel: transactionModel,
                action: action
            )

        case .selectSource:
            switch action {
            case .buy:
                if newState.stepsBackStack.contains(.enterAmount) {
                    router?.presentSourceAccountPicker(
                        transactionModel: transactionModel,
                        action: action
                    )
                } else {
                    router?.routeToSourceAccountPicker(
                        transactionModel: transactionModel,
                        action: action
                    )
                }

            case .deposit,
                 .withdraw,
                 .sell,
                 .swap,
                 .send,
                 .receive,
                 .viewActivity:
                router?.routeToSourceAccountPicker(
                    transactionModel: transactionModel,
                    action: action
                )
            }

        case .enterAddress:
            router?.routeToDestinationAccountPicker(
                transactionModel: transactionModel,
                action: action
            )

        case .closed:
            transactionModel.destroy()
        }
    }

    private func handleFiatDeposit(
        sourceAccount: BlockchainAccount?,
        target: TransactionTarget?,
        passwordRequired: Bool
    ) -> TransactionAction {
        if let source = sourceAccount, let target = target {
            return .initialiseWithSourceAndTargetAccount(
                action: .deposit,
                sourceAccount: source,
                target: target,
                passwordRequired: passwordRequired
            )
        }
        if let source = sourceAccount {
            return .initialiseWithSourceAccount(
                action: .deposit,
                sourceAccount: source,
                passwordRequired: passwordRequired
            )
        }
        if let target = target {
            return .initialiseWithTargetAndNoSource(
                action: .deposit,
                target: target,
                passwordRequired: passwordRequired
            )
        }
        return .initialiseWithNoSourceOrTargetAccount(
            action: .deposit,
            passwordRequired: passwordRequired
        )
    }
}
