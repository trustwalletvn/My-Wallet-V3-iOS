// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A response for `simple-buy/pairs`
struct SupportedPairsResponse: Decodable {

    // MARK: - Types

    struct Pair: Decodable {

        /// Possible pair with the format: `BTC-USD`
        let pair: String

        /// Min fiat amount to buy (`1000` ~ 10.00 Fiat)
        let buyMin: String

        /// Max fiat amount to buy (`100000` ~ 1000.00 Fiat)
        let buyMax: String
    }

    /// The pairs
    let pairs: [Pair]
}
