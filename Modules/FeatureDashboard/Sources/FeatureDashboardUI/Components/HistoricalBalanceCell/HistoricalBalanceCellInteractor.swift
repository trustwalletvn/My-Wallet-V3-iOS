// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class HistoricalBalanceCellInteractor {

    // MARK: - Properties

    let sparklineInteractor: SparklineInteracting
    let priceInteractor: AssetPriceViewInteracting
    let balanceInteractor: AssetBalanceViewInteracting
    let cryptoCurrency: CryptoCurrency

    // MARK: - Setup

    init(
        cryptoAsset: CryptoAsset,
        historicalFiatPriceService: HistoricalFiatPriceServiceAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        cryptoCurrency = cryptoAsset.asset
        sparklineInteractor = SparklineInteractor(
            priceService: historicalFiatPriceService,
            cryptoCurrency: cryptoCurrency
        )
        priceInteractor = AssetPriceViewInteractor(
            historicalPriceProvider: historicalFiatPriceService
        )
        balanceInteractor = AccountAssetBalanceViewInteractor(
            cryptoAsset: cryptoAsset,
            fiatCurrencyService: fiatCurrencyService
        )
    }

    func refresh() {
        balanceInteractor.refresh()
    }
}
