// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension MoneyValuePair {

    /// Returns a new `MoneyValuePair` instance intended to get the inverse FX quote from an existing quote.
    /// This means that given a FX quote like 1 BTC = 50,000 USD, this will return a new quote => 1 USD  = 1 / 50,000 BTC.
    public var inverseQuote: MoneyValuePair {
        // `try`s are disabled here as this operation can never fail.
        // If it failed, it would be a developer error and thus it's better to crash.
        guard !base.isZero, !quote.isZero else {
            // swiftlint:disable:next force_try
            return try! MoneyValuePair(
                base: .zero(currency: quote.currency),
                exchangeRate: .zero(currency: base.currency)
            )
        }

        // swiftlint:disable:next force_try
        return try! MoneyValuePair(
            base: .one(currency: quote.currencyType),
            exchangeRate: base.convert(
                usingInverse: quote,
                currencyType: base.currencyType
            )
        )
    }
}
