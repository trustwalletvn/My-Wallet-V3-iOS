// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

final class CardAuthorizationScreenInteractor: Interactor {

    private let routingInteractor: CardAuthorizationRoutingInteractorAPI

    init(routingInteractor: CardAuthorizationRoutingInteractorAPI) {
        self.routingInteractor = routingInteractor
    }

    func cardAuthorized(with identifier: String) {
        routingInteractor.cardAuthorized(with: identifier)
    }
}
