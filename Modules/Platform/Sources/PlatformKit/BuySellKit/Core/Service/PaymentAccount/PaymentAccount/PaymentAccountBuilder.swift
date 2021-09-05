// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Builds the correct `PaymentAccount` for a given `PaymentAccountResponse`.
enum PaymentAccountBuilder {

    // MARK: - Private Properties

    /// An array of possible `PaymentAccount.Type`s
    private static let builders: [PaymentAccountDescribing.Type] = [
        PaymentAccountGBP.self,
        PaymentAccountEUR.self,
        PaymentAccountUSD.self
    ]

    // MARK: - Methods

    /// Builds, if possible, a valid `Payment Account` for the given `Payment Account Response`
    /// - Parameter response: A `PaymentAccountResponse` object.
    /// - Returns: A `PaymentAccount` object if there was a `PaymentAccount.Type`  that succesfully built a valid object
    /// or `nil` if no builder succeeded.
    static func build(response: PlatformKit.PaymentAccount) -> PaymentAccountDescribing? {
        for builder in builders {
            if let result = builder.init(response: response) {
                return result
            }
        }
        return nil
    }
}
