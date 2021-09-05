// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import ToolKit

public protocol CardComponentBuilderAPI: AnyObject {

    /// Builds a card details screen
    func cardDetails() -> UIViewController

    /// Builds a billing address screen
    func billingAddress(for cardData: CardData, navigationControllerAPI: NavigationControllerAPI) -> UIViewController

    /// Builds a pending card status screen (hangs until card is approved)
    func pendingCardStatus(cardId: String) -> UIViewController

    /// Builds a card authorization screen
    func cardAuthorization(for data: PartnerAuthorizationData) -> UIViewController
}

public final class CardComponentBuilder: CardComponentBuilderAPI {

    private let routingInteractor: CardRouterInteractor
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let messageRecorder: MessageRecording
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI

    public init(
        routingInteractor: CardRouterInteractor,
        paymentMethodTypesService: PaymentMethodTypesServiceAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        messageRecorder: MessageRecording = resolve()
    ) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.routingInteractor = routingInteractor
        self.analyticsRecorder = analyticsRecorder
        self.messageRecorder = messageRecorder
    }

    public func cardDetails() -> UIViewController {
        let interactor = CardDetailsScreenInteractor(
            routingInteractor: routingInteractor
        )
        let presenter = CardDetailsScreenPresenter(
            interactor: interactor,
            eventRecorder: analyticsRecorder,
            messageRecorder: messageRecorder
        )
        let viewController = CardDetailsScreenViewController(presenter: presenter)
        return viewController
    }

    public func pendingCardStatus(cardId: String) -> UIViewController {
        let interactor = PendingCardStatusInteractor(
            cardId: cardId,
            paymentMethodTypesService: paymentMethodTypesService,
            routingInteractor: routingInteractor
        )
        let presenter = PendingCardStatusPresenter(interactor: interactor)
        let viewController = PendingStateViewController(
            presenter: presenter
        )
        return viewController
    }

    public func cardAuthorization(for data: PartnerAuthorizationData) -> UIViewController {
        let interactor = CardAuthorizationScreenInteractor(routingInteractor: routingInteractor)
        let presenter = CardAuthorizationScreenPresenter(
            interactor: interactor,
            data: data,
            eventRecorder: analyticsRecorder
        )
        let viewController = CardAuthorizationScreenViewController(
            presenter: presenter
        )
        return viewController
    }

    public func billingAddress(for cardData: CardData, navigationControllerAPI: NavigationControllerAPI) -> UIViewController {
        // TODO: Move `SelectionRouter` to RIBs
        let selectionRouter = SelectionRouter(parent: navigationControllerAPI)
        let interactor = BillingAddressScreenInteractor(
            cardData: cardData,
            routingInteractor: routingInteractor
        )
        let presenter = BillingAddressScreenPresenter(
            interactor: interactor,
            countrySelectionRouter: selectionRouter,
            eventRecorder: analyticsRecorder,
            messageRecorder: messageRecorder
        )
        let viewController = BillingAddressScreenViewController(
            presenter: presenter
        )
        return viewController
    }
}
