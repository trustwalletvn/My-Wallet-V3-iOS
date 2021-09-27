// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import ToolKit

extension DependencyContainer {

    // MARK: - ERC20Kit Module

    public static var erc20Kit = module {

        // MARK: Asset Agnostic

        single(tag: Tags.ERC20AccountService.isContractAddressCache) {
            Atomic<[String: Bool]>([:])
        }

        factory(tag: AssetModelType.erc20) { ERC20ExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        factory { ERC20AssetFactory() as ERC20AssetFactoryAPI }

        single { ERC20HistoricalTransactionService() as ERC20HistoricalTransactionServiceAPI }

        factory { ERC20AccountDetailsService() as ERC20AccountDetailsServiceAPI }

        factory { ERC20BalanceService() as ERC20BalanceServiceAPI }

        factory { ERC20AccountAPIClient() as ERC20AccountAPIClientAPI }

        factory { ERC20AccountService() as ERC20AccountServiceAPI }
    }
}

extension DependencyContainer {
    enum Tags {
        enum ERC20AccountService {
            static let isContractAddressCache = String(describing: Self.self)
        }
    }
}
