// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import RxSwift
@testable import TransactionKit
import XCTest

final class SwapQuotesEngineMock {
    private let service: OrderQuoteRepositoryMock
    private let amount = BehaviorSubject<BigInt>(value: .zero)
    private var amountObservable: Observable<BigInt> {
        amount
            .asObservable()
    }

    init(service: OrderQuoteRepositoryMock = OrderQuoteRepositoryMock()) {
        self.service = service
    }

    func getRate(direction: OrderDirection = .internal, pair: OrderPair) -> Observable<BigInt> {
        Observable.combineLatest(
            service
                .latestQuote
                .asObservable(),
            amountObservable
        )
        .map { quote, amount -> BigInt in
            PricesInterpolator(prices: quote.quote.priceTiers).rate(amount: amount)
        }
    }

    func updateAmount(_ amount: BigInt) {
        self.amount.onNext(amount)
    }
}
