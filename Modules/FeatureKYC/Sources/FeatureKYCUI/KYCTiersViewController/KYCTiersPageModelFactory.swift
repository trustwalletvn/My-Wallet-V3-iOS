// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public protocol KYCTiersPageModelFactoryAPI: AnyObject {
    func tiersPageModel(suppressCTA: Bool) -> Single<KYCTiersPageModel>
}

final class KYCTiersPageModelFactory: KYCTiersPageModelFactoryAPI {

    private let limitsAPI: TradeLimitsAPI
    private let tiersService: KYCTiersServiceAPI
    private let currencyService: FiatCurrencyServiceAPI

    init(
        limitsAPI: TradeLimitsAPI = resolve(),
        currencyService: FiatCurrencyServiceAPI = resolve(),
        tiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.limitsAPI = limitsAPI
        self.currencyService = currencyService
        self.tiersService = tiersService
    }

    func tiersPageModel(suppressCTA: Bool) -> Single<KYCTiersPageModel> {
        currencyService.fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<(TradeLimits?, KYC.UserTiers, FiatCurrency)> in
                let tradeLimits = self.limitsAPI
                    .getTradeLimits(withFiatCurrency: fiatCurrency.code, ignoringCache: true)
                    .optional()
                    .catchErrorJustReturn(nil)

                return Single.zip(tradeLimits, self.tiersService.tiers, .just(fiatCurrency))
            }
            .map { tradeLimits, tiers, fiatCurrency -> (FiatValue, KYC.UserTiers) in
                guard tiers.tierAccountStatus(for: .tier1).isApproved else {
                    return (FiatValue.zero(currency: fiatCurrency), tiers)
                }
                let maxTradableToday = FiatValue.create(
                    major: tradeLimits?.maxTradableToday ?? 0,
                    currency: fiatCurrency
                )
                return (maxTradableToday, tiers)
            }
            .map { maxTradableToday, tiers -> KYCTiersPageModel in
                KYCTiersPageModel.make(tiers: tiers, maxTradableToday: maxTradableToday, suppressCTA: suppressCTA)
            }
    }
}
