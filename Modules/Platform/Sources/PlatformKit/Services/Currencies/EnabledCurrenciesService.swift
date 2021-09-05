// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

public protocol EnabledCurrenciesServiceAPI {
    var allEnabledCurrencies: [CurrencyType] { get }
    var allEnabledCryptoCurrencies: [CryptoCurrency] { get }
    var allEnabledFiatCurrencies: [FiatCurrency] { get }
    /// This returns the supported currencies that a user can link a bank through a partner, eg Yodlee
    var bankTransferEligibleFiatCurrencies: [FiatCurrency] { get }
}

final class EnabledCurrenciesService: EnabledCurrenciesServiceAPI {

    private let nonCustodialCryptoCurrencies: [CryptoCurrency] = [
        .coin(.bitcoin),
        .coin(.ethereum),
        .coin(.bitcoinCash),
        .coin(.stellar)
    ].sorted()

    private lazy var custodialCurrencies: [CryptoCurrency] = {
        repository.custodialAssets
            .currencies
            .filter { !NonCustodialCoinCode.allCases.map(\.rawValue).contains($0.code) }
            .filter(\.products.enablesCurrency)
            .compactMap {
                switch $0 {
                case let model as CoinAssetModel:
                    return .coin(model)
                case let model as ERC20AssetModel:
                    return .erc20(model)
                default:
                    return nil
                }
            }
    }()

    lazy var allEnabledCryptoCurrencies: [CryptoCurrency] = {
        (nonCustodialCryptoCurrencies + custodialCurrencies).sorted()
    }()

    lazy var allEnabledCurrencies: [CurrencyType] = {
        let crypto: [CurrencyType] = allEnabledCryptoCurrencies
            .map { .crypto($0) }
        let fiat: [CurrencyType] = allEnabledFiatCurrencies
            .map { .fiat($0) }
        return crypto + fiat
    }()

    let allEnabledFiatCurrencies: [FiatCurrency] = [.USD, .EUR, .GBP]

    var bankTransferEligibleFiatCurrencies: [FiatCurrency] {
        [.USD]
    }

    private let featureFlagService: InternalFeatureFlagServiceAPI
    private let featureConfigurator: FeatureConfiguring
    private let repository: SupportedAssetsRepositoryAPI

    init(
        featureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        featureConfigurator: FeatureConfiguring = resolve(),
        repository: SupportedAssetsRepositoryAPI = resolve()
    ) {
        self.featureFlagService = featureFlagService
        self.featureConfigurator = featureConfigurator
        self.repository = repository
    }
}
