// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RIBs

protocol SendRootInteractable: Interactable, TransactionFlowListener {
    var router: SendRootRouting? { get set }
    var listener: SendRootListener? { get set }
}

final class SendRootRouter: ViewableRouter<SendRootInteractable, SendRootViewControllable>, SendRootRouting {

    // MARK: - Types

    private typealias LocalizedSend = LocalizationConstants.Send

    // MARK: - Private Properties

    private var transactionRouter: ViewableRouting?
    private let analyticsHook: TransactionAnalyticsHook

    // MARK: - Init

    init(
        interactor: SendRootInteractable,
        viewController: SendRootViewControllable,
        analyticsHook: TransactionAnalyticsHook = resolve()
    ) {
        self.analyticsHook = analyticsHook
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - SwapRootRouting

    func routeToSendLanding() {
        let header = AccountPickerHeaderModel(
            title: LocalizedSend.Header.sendCryptoNow,
            subtitle: LocalizedSend.Header.chooseAWalletToSendFrom,
            imageContent: .init(
                imageResource: ImageAsset.iconSend.imageResource,
                accessibility: .none,
                renderingMode: .normal
            )
        )
        let navigationModel = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .none,
            titleViewStyle: .text(value: LocalizedSend.Text.send),
            barStyle: .lightContent()
        )
        let builder = AccountPickerBuilder(
            singleAccountsOnly: true,
            action: .send
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            guard let cryptoAccount = account as? CryptoAccount else {
                fatalError("Expected a CryptoAccount: \(account)")
            }
            self?.analyticsHook.onFromAccountSelected(cryptoAccount, action: .send)
            self?.routeToSend(sourceAccount: cryptoAccount)
        }
        let sendAccountPickerRouter = builder.build(
            listener: .simple(didSelect),
            navigationModel: navigationModel,
            headerModel: .default(header)
        )
        attachChild(sendAccountPickerRouter)
        viewController.replaceRoot(
            viewController: sendAccountPickerRouter.viewControllable,
            animated: false
        )
    }

    func routeToSend(sourceAccount: CryptoAccount) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .send,
            sourceAccount: sourceAccount,
            target: nil
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable
            attachChild(router)
            viewController.present(viewController: viewControllable)
        }
    }

    func routeToSend(sourceAccount: CryptoAccount, destination: TransactionTarget) {
        let builder = TransactionFlowBuilder()
        transactionRouter = builder.build(
            withListener: interactor,
            action: .send,
            sourceAccount: sourceAccount,
            target: destination
        )
        if let router = transactionRouter {
            let viewControllable = router.viewControllable
            attachChild(router)
            viewController.present(viewController: viewControllable)
        }
    }

    func dismissTransactionFlow() {
        guard let router = transactionRouter else { return }
        detachChild(router)
        transactionRouter = nil
    }
}
