// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct CryptoExchangeAddressRequest: Encodable {
    /// Currency should be the `Currency.code`
    let currency: String

    init(currency: CryptoCurrency) {
        self.currency = currency.code
    }
}
