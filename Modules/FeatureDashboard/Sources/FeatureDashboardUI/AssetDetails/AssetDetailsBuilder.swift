// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import PlatformUIKit
import UIKit

final class AssetDetailsBuilder {

    private let accountsRouter: AccountsRouting
    private let currency: CryptoCurrency
    private let exchangeProviding: ExchangeProviding

    init(
        accountsRouter: AccountsRouting,
        currency: CryptoCurrency,
        exchangeProviding: ExchangeProviding
    ) {
        self.accountsRouter = accountsRouter
        self.currency = currency
        self.exchangeProviding = exchangeProviding
    }

    func build() -> UIViewController {
        let interactor = AssetDetailsScreenInteractor(
            currency: currency,
            exchangeAPI: exchangeProviding[currency]
        )
        let presenter = AssetDetailsScreenPresenter(
            accountsRouter: accountsRouter,
            using: interactor,
            with: currency
        )
        return AssetDetailsViewController(using: presenter)
    }
}
