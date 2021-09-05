// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class FiatCurrencySelectionProvider: FiatCurrencySelectionProviderAPI {
    public var currencies: Observable<[FiatCurrency]> {
        supportedCurrencies.supportedCurrencies
            .map { Array($0) }
            .asObservable()
    }

    private let supportedCurrencies: SupportedCurrenciesServiceAPI

    public init(supportedCurrencies: SupportedCurrenciesServiceAPI = resolve()) {
        self.supportedCurrencies = supportedCurrencies
    }
}
