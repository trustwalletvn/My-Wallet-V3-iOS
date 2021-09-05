// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

/// Provides an API for building sell components
public protocol SellBuilderAPI: AnyObject {

    var routerInteractor: SellRouterInteractor { get }

    /// Builds the `BuySellKYCInvalidViewController` screen.
    /// Shown to users who have been rejected from KYC.
    func buySellKYCInvalidViewController() -> UIViewController

    /// Builds the `ineligible` screen where the user is shown
    /// that due to their KYC status or region, they are not eligible
    /// for `Sell`
    func ineligibleViewController() -> UIViewController

    /// Start of `Sell` if the user has not completed KYC.
    func sellIdentityIntroductionViewController() -> UIViewController

    /// Start of `Sell`. Builds the account selection screen.
    func accountSelectionRouter() -> AccountPickerRouting

    /// Builds the fiat account selection screen.
    func fiatAccountSelectionRouter() -> AccountPickerRouting

    /// Builds and provides a sell crypto VIP stack, based on `EnterAmountScreenViewController`.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func sellCryptoViewController(data: SellCryptoInteractionData) -> UIViewController

    /// Builds and provides a checkout VIP stack.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func checkoutScreenViewController(data: CheckoutData) -> UIViewController

    /// Builds and provides a pending VIP stack.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func pendingScreenViewController(for orderDetails: OrderDetails) -> UIViewController

    /// Builds and provides a transfer cancellation VIP stack.
    /// - Parameter data: The data required for building the interaction state
    /// - Returns: A `UIViewController` instance to show within a `UINavigationController`.
    func transferCancellationViewController(data: CheckoutData) -> UIViewController
}

/// Builds sell components
public final class SellBuilder: SellBuilderAPI {

    // MARK: - Public Properties

    public let routerInteractor: SellRouterInteractor

    // MARK: - Private Properties

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let priceService: PriceServiceAPI
    private let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    private let accountSelectionService: AccountSelectionServiceAPI

    // MARK: - Setup

    public init(
        accountSelectionService: AccountSelectionServiceAPI,
        routerInteractor: SellRouterInteractor,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve()
    ) {
        self.accountSelectionService = accountSelectionService
        self.analyticsRecorder = analyticsRecorder
        self.supportedPairsInteractor = supportedPairsInteractor
        self.priceService = priceService
        self.routerInteractor = routerInteractor
    }

    // MARK: - SellBuilderAPI

    public func buySellKYCInvalidViewController() -> UIViewController {
        let presenter = BuySellKYCInvalidScreenPresenter(routerInteractor: routerInteractor)
        return BuySellKYCInvalidViewController(presenter: presenter)
    }

    public func accountSelectionRouter() -> AccountPickerRouting {
        let builder = AccountPickerBuilder(
            singleAccountsOnly: true,
            action: .sell
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            self?.accountSelectionService.record(selection: account)
            if let account = account as? CryptoAccount {
                self?.analyticsRecorder.record(event:
                    AnalyticsEvents.New.Sell.sellFromSelected(
                        fromAccountType: .init(account),
                        inputCurrency: account.currencyType.code
                    )
                )
            }
        }
        let router = builder.build(
            listener: .simple(didSelect),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(),
            headerModel: .none
        )
        return router
    }

    public func fiatAccountSelectionRouter() -> AccountPickerRouting {
        let builder = AccountPickerBuilder(
            singleAccountsOnly: true,
            action: .deposit
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            self?.accountSelectionService.record(selection: account)
        }
        let router = builder.build(
            listener: .simple(didSelect),
            navigationModel: ScreenNavigationModel.AccountPicker.modal(),
            headerModel: .none
        )
        return router
    }

    public func sellCryptoViewController(data: SellCryptoInteractionData) -> UIViewController {
        let cryptoSelectionService = CryptoCurrencySelectionService(
            service: supportedPairsInteractor,
            defaultSelectedData: data.source.currencyType.cryptoCurrency!
        )
        let interactor = SellCryptoScreenInteractor(
            data: data,
            priceService: priceService,
            cryptoCurrencySelectionService: cryptoSelectionService,
            initialActiveInput: .fiat
        )
        let presenter = SellCryptoScreenPresenter(
            interactor: interactor,
            routerInteractor: routerInteractor,
            backwardsNavigation: { [weak routerInteractor] () -> Void in
                routerInteractor?.previousRelay.accept(())
            }
        )
        let viewController = EnterAmountScreenViewController(presenter: presenter)
        return viewController
    }

    public func sellIdentityIntroductionViewController() -> UIViewController {
        let presenter = SellIdentityIntroductionPresenter(interactor: routerInteractor)
        let controller = SellIdentityIntroductionViewController(presenter: presenter)
        return controller
    }

    public func pendingScreenViewController(for orderDetails: OrderDetails) -> UIViewController {
        let interactor = PendingOrderStateScreenInteractor(
            orderDetails: orderDetails
        )
        let presenter = PendingOrderStateScreenPresenter(
            routingInteractor: SellPendingOrderRoutingInteractor(interactor: routerInteractor),
            interactor: interactor
        )
        let viewController = PendingStateViewController(
            presenter: presenter
        )
        return viewController
    }

    public func transferCancellationViewController(data: CheckoutData) -> UIViewController {
        let interactor = TransferCancellationInteractor(
            checkoutData: data
        )

        let presenter = TransferCancellationScreenPresenter(
            routingInteractor: SellTransferCancellationRoutingInteractor(
                routingInteractor: routerInteractor
            ),
            currency: data.outputCurrency,
            interactor: interactor
        )
        let viewController = TransferCancellationViewController(presenter: presenter)
        return viewController
    }

    public func checkoutScreenViewController(data: CheckoutData) -> UIViewController {
        let orderInteractor = SellOrderCheckoutInteractor(
            fundsAndBankInteractor: FundsAndBankOrderCheckoutInteractor()
        )
        let interactor = CheckoutScreenInteractor(
            orderCheckoutInterator: orderInteractor,
            checkoutData: data
        )
        let presenter = CheckoutScreenPresenter(
            checkoutRouting: SellCheckoutRoutingInteractor(
                interactor: routerInteractor
            ),
            contentReducer: SellCheckoutContentReducer(data: data),
            interactor: interactor
        )
        let viewController = DetailsScreenViewController(presenter: presenter)
        return viewController
    }

    public func ineligibleViewController() -> UIViewController {
        let presenter = BuySellIneligibleScreenPresenter(
            interactor: BuySellIneligibleScreenInteractor(),
            router: routerInteractor
        )
        let controller = BuySellIneligibleRegionViewController(presenter: presenter)
        return controller
    }
}
