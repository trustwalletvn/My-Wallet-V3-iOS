// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class InputAmountLabelInteractor {

    // MARK: - Properties

    public let scanner: MoneyValueInputScanner
    public let interactor: AmountLabelViewInteractor

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(currency: Currency, integralPlacesLimit: Int = 10) {
        scanner = MoneyValueInputScanner(
            maxDigits: .init(integral: integralPlacesLimit, fractional: currency.maxDisplayableDecimalPlaces)
        )
        interactor = AmountLabelViewInteractor(currency: currency)

        interactor.currency
            .map { .init(integral: integralPlacesLimit, fractional: $0.maxDisplayableDecimalPlaces) }
            .bindAndCatch(to: scanner.maxDigitsRelay)
            .disposed(by: disposeBag)
    }
}
