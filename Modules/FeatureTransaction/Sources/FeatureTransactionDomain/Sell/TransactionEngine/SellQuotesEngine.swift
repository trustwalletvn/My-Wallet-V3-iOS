// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import DIKit
import PlatformKit

final class SellQuotesEngine {

    // MARK: - Private Properties

    private let stopSubject = PassthroughSubject<Void, Never>()
    private let repository: OrderQuoteRepositoryAPI
    private let amount = CurrentValueSubject<BigInt, Never>(.zero)

    // MARK: - Init

    init(repository: OrderQuoteRepositoryAPI = resolve()) {
        self.repository = repository
    }

    // MARK: - Public Functions

    func stop() {
        stopSubject.send(())
    }

    func updateAmount(_ amount: BigInt) {
        self.amount.send(amount)
    }

    // MARK: - Private Functions

    private func fetchQuote(
        direction: OrderDirection,
        pair: OrderPair
    ) -> AnyPublisher<OrderQuotePayload, NabuNetworkError> {
        repository
            .fetchQuote(
                direction: direction,
                sourceCurrencyType: pair.sourceCurrencyType,
                destinationCurrencyType: pair.destinationCurrencyType
            )
            .eraseToAnyPublisher()
    }
}
