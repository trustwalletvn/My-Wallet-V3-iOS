// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class BuySellActivityDetailsInteractor {

    private let cardListService: CardListServiceAPI

    init(cardListService: CardListServiceAPI = resolve()) {
        self.cardListService = cardListService
    }

    func fetchCardDetails(for paymentMethodId: String?) -> Single<CardData?> {
        cardListService
            .card(by: paymentMethodId ?? "")
    }
}
