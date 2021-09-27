// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    public static var featureTransactionDomain = module {

        factory { CryptoTargetPayloadFactory() as CryptoTargetPayloadFactoryAPI }

        factory { AvailableTradingPairsService() as AvailableTradingPairsServiceAPI }

        factory { PendingSwapCompletionService() as PendingSwapCompletionServiceAPI }

        factory { BlockchainNameResolutionService() as BlockchainNameResolutionServiceAPI }

        factory { () -> CryptoCurrenciesServiceAPI in
            CryptoCurrenciesService(
                pairsService: DIKit.resolve(),
                priceService: DIKit.resolve()
            )
        }

        factory { PaymentAccountsService() as FeatureTransactionDomain.PaymentAccountsServiceAPI }
    }
}
