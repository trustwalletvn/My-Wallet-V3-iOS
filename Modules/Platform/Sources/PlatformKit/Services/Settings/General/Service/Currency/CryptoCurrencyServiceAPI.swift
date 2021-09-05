// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CryptoCurrencyServiceAPI: CurrencyServiceAPI {

    /// An `Observable` that streams `CryptoCurrency` values
    var cryptoCurrencyObservable: Observable<CryptoCurrency> { get }

    /// A `Single` that streams `CryptoCurrency` values
    var cryptoCurrency: Single<CryptoCurrency> { get }
}

extension CryptoCurrencyServiceAPI {

    public var currencyObservable: Observable<Currency> {
        cryptoCurrencyObservable.map { $0 as Currency }
    }

    public var currency: Single<Currency> {
        cryptoCurrency.map { $0 as Currency }
    }
}

public class DefaultCryptoCurrencyService: CryptoCurrencyServiceAPI {
    public enum ServiceError: Error {
        case unexpectedCurrencyType
    }

    public var cryptoCurrencyObservable: Observable<CryptoCurrency> {
        cryptoCurrency.asObservable()
    }

    public var cryptoCurrency: Single<CryptoCurrency> {
        guard case .crypto(let crypto) = value else {
            return .error(ServiceError.unexpectedCurrencyType)
        }
        return .just(crypto)
    }

    private let value: CurrencyType

    public init(currencyType: CurrencyType) {
        value = currencyType
    }
}
