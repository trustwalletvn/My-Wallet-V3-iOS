// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import RIBs
import RxSwift
import SafariServices
import ToolKit

public final class SellRouter: RIBs.Router<SellRouterInteractor> {

    // MARK: - Injected

    private let routingType: RoutingType
    private let navigationRouter: NavigationRouterAPI
    private let builder: SellBuilderAPI
    private let kycRouter: KYCRouterAPI

    /// A kyc subscription dispose bag
    private var kycDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()

    public init(
        routingType: RoutingType = .modal,
        navigationRouter: NavigationRouterAPI = NavigationRouter(),
        kycRouter: KYCRouterAPI = resolve(),
        builder: SellBuilderAPI
    ) {
        self.kycRouter = kycRouter
        self.navigationRouter = navigationRouter
        self.routingType = routingType
        self.builder = builder
        super.init(interactor: builder.routerInteractor)
    }

    // MARK: - Lifecycle

    override public func didLoad() {
        super.didLoad()

        // Embed the entire flow in another navigation controller
        // instead of generating one of its own
        if case .embed(inside: let navigationController) = routingType {
            navigationRouter.navigationControllerAPI = navigationController
        }

        // Action is a steam of events derived from a pblish relay
        interactor.action
            .emit(weak: self) { (self, action) in
                switch action {
                case .previous(from: let state):
                    self.previous(from: state)
                case .next(to: let state):
                    self.next(to: state)
                case .dismiss:
                    self.navigationRouter.navigationControllerAPI?.dismiss(animated: true, completion: nil)
                }
            }
            .disposed(by: disposeBag)

        // TODO: Remove once `AppCoordinator` moves into RIBs because Should be automatically
        /// called by `Router` once `self` is attached as a child router.
        interactor.activate()
    }

    private func next(to state: SellRouterInteractor.State) {
        switch state {
        case .accountSelector:
            navigateToAccountSelectorScreen()
        case .fiatAccountSelector:
            navigationRouter.dismiss { [weak self] in
                guard let self = self else { return }
                self.navigateToFiatAccountSelectorScreen()
            }
        case .checkout(let data):
            navigationToCheckoutScreen(with: data)
        case .kyc:
            switch navigationRouter.navigationControllerAPI != nil {
            case true:
                navigationRouter.dismiss { [weak self] in
                    guard let self = self else { return }
                    self.showKYC()
                }
            case false:
                showKYC()
            }
        case .introduction:
            navigateToSellIntroductionScreen()
        case .ineligible:
            navigateToIneligibleScreen()
        case .verificationFailed:
            navigateToVerificationFailedScreen()
        case .ineligibilityURL:
            navigateToIneligibilityPage()
        case .contactSupportURL:
            navigateToContactSupportPage()
        case .cancel:
            break
        case .pendingOrderCompleted(orderDetails: let orderDetails):
            navigateToPendingScreen(orderDetails: orderDetails)
        case .completed,
             .inactive:
            break
        case .enterAmount(let data):
            navigationRouter.dismiss { [weak self] in
                guard let self = self else { return }
                self.navigateToEnterAmountScreen(with: data)
            }
        }
    }

    private func previous(from state: SellRouterInteractor.State) {
        switch state {
        case .inactive:
            fatalError("\(state.debugDescription) state must not be reached")
        case .enterAmount,
             .checkout,
             .completed,
             .cancel,
             .accountSelector,
             .pendingOrderCompleted,
             .fiatAccountSelector,
             .introduction,
             .kyc,
             .ineligibilityURL,
             .contactSupportURL,
             .ineligible,
             .verificationFailed:
            navigationRouter.dismiss()
        }
    }

    // MARK: - Navigation Accessors

    private func showKYC() {
        kycDisposeBag = DisposeBag()
        kycRouter.kycStopped
            .take(1)
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: interactor.previousRelay)
            .disposed(by: kycDisposeBag)

        let finished = kycRouter.kycFinished
            .take(1)
            .observeOn(MainScheduler.instance)
            .share()

        finished
            .filter { $0 == .tier2 }
            .mapToVoid()
            .bindAndCatch(weak: self) { (self) in
                self.interactor.nextFromKYC()
            }
            .disposed(by: kycDisposeBag)

        finished
            .filter { $0 != .tier2 }
            .mapToVoid()
            .bindAndCatch(to: interactor.previousRelay)
            .disposed(by: kycDisposeBag)

        kycRouter.start(tier: .tier2, parentFlow: .simpleBuy)
    }

    private func navigateToVerificationFailedScreen() {
        navigationRouter.present(viewController: builder.buySellKYCInvalidViewController())
    }

    private func navigateToContactSupportPage() {
        navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            guard let top = self.navigationRouter.topMostViewControllerProvider.topMostViewController else { return }
            guard let url = URL(string: "https://support.blockchain.com/hc/en-us/requests/new?ticket_form_id=360000186571") else { return }
            let controller = SFSafariViewController(url: url)
            controller.modalPresentationStyle = .overCurrentContext
            top.present(controller, animated: true, completion: nil)
        })
    }

    private func navigateToIneligibilityPage() {
        navigationRouter.topMostViewControllerProvider.topMostViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else { return }
            guard let top = self.navigationRouter.topMostViewControllerProvider.topMostViewController else { return }
            // swiftlint:disable line_length
            guard let url = URL(string: "https://support.blockchain.com/hc/en-us/articles/360040015211-What-countries-are-supported-for-Buy-Crypto-") else { return }
            let controller = SFSafariViewController(url: url)
            controller.modalPresentationStyle = .overCurrentContext
            top.present(controller, animated: true, completion: nil)
        })
    }

    private func navigateToIneligibleScreen() {
        let viewController = builder.ineligibleViewController()
        viewController.transitioningDelegate = sheetPresenter
        viewController.modalPresentationStyle = .custom
        navigationRouter.topMostViewControllerProvider.topMostViewController?.present(viewController, animated: true, completion: nil)
    }

    private func navigateToSellIntroductionScreen() {
        let viewController = builder.sellIdentityIntroductionViewController()
        navigationRouter.present(viewController: viewController)
    }

    private func navigateToPendingScreen(orderDetails: OrderDetails) {
        let viewController = builder.pendingScreenViewController(for: orderDetails)
        navigationRouter.present(viewController: viewController)
    }

    private func navigateToTransferCancellation(with data: CheckoutData) {
        let viewController = builder.transferCancellationViewController(data: data)
        navigationRouter.present(viewController: viewController)
    }

    private func navigateToFiatAccountSelectorScreen() {
        let router = builder.fiatAccountSelectionRouter()
        attachChild(router)
        navigationRouter.present(
            viewController: router.viewControllable.uiviewController,
            using: .modalOverTopMost
        )
    }

    private func navigateToAccountSelectorScreen() {
        let router = builder.accountSelectionRouter()
        attachChild(router)
        navigationRouter.present(viewController: router.viewControllable.uiviewController)
    }

    private func navigateToEnterAmountScreen(with data: SellCryptoInteractionData) {
        let viewController = builder.sellCryptoViewController(data: data)
        navigationRouter.present(viewController: viewController, using: .modalOverTopMost)
    }

    private func navigationToCheckoutScreen(with data: CheckoutData) {
        let viewController = builder.checkoutScreenViewController(data: data)
        navigationRouter.present(viewController: viewController)
    }

    private lazy var sheetPresenter: BottomSheetPresenting = {
        BottomSheetPresenting(ignoresBackroundTouches: false)
    }()
}
