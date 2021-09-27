// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit

extension DependencyContainer {

    // MARK: - BitcoinChainKit Module

    public static var bitcoinChainKit = module {

        // MARK: - Bitcoin

        factory(tag: BitcoinChainCoin.bitcoin) { APIClient(coin: .bitcoin) as APIClientAPI }

        factory(tag: BitcoinChainCoin.bitcoin) { BalanceService(coin: .bitcoin) as BalanceServiceAPI }

        factory(tag: BitcoinChainCoin.bitcoin) { AnyCryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>>.bitcoin() }

        factory(tag: CoinAssetModel.bitcoin.typeTag) { BitcoinChainExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        factory { CryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>>() }

        // MARK: - Bitcoin Cash

        factory(tag: BitcoinChainCoin.bitcoinCash) { APIClient(coin: .bitcoinCash) as APIClientAPI }

        factory(tag: BitcoinChainCoin.bitcoinCash) { BalanceService(coin: .bitcoinCash) as BalanceServiceAPI }

        factory(tag: BitcoinChainCoin.bitcoinCash) { AnyCryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>>.bitcoinCash() }

        factory(tag: CoinAssetModel.bitcoinCash.typeTag) { BitcoinChainExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        factory { CryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>>() }
    }
}

extension AnyCryptoFeeService where FeeType == BitcoinChainTransactionFee<BitcoinToken> {
    fileprivate static func bitcoin(
        service: CryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>> = resolve()
    ) -> AnyCryptoFeeService<FeeType> {
        AnyCryptoFeeService<FeeType>(service: service)
    }
}

extension AnyCryptoFeeService where FeeType == BitcoinChainTransactionFee<BitcoinCashToken> {
    fileprivate static func bitcoinCash(
        service: CryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>> = resolve()
    ) -> AnyCryptoFeeService<FeeType> {
        AnyCryptoFeeService<FeeType>(service: service)
    }
}
