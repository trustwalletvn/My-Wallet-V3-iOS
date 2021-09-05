// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol FiatCurrencySettingsServiceAPI: FiatCurrencyServiceAPI {

    /// Updates the fiat currency associated with the wallet
    /// - Parameter currency: The new fiat currency
    /// - Parameter context: The context in which the request has happened
    /// - Returns: A `Completable`
    func update(currency: FiatCurrency, context: FlowContext) -> Completable

    /// Updates the fiat currency associated with the wallet
    /// - Parameter currency: The new fiat currency
    /// - Parameter context: The context in which the request has happened
    /// - Returns: A `AnyPublisher<Void, Error>`
    func update(currency: FiatCurrency, context: FlowContext) -> AnyPublisher<Void, CurrencyUpdateError>
}
