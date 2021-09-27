// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import RxSwift
import ToolKit
import WalletCore

final class BitcoinChainExternalAssetAddressFactory: CryptoReceiveAddressFactory {

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        switch asset {
        case .coin(.bitcoin):
            let address = address.removing(prefix: "\(BitcoinURLPayload.scheme):")
            guard WalletCore.CoinType.bitcoin.validate(address: address) else {
                return .failure(.invalidAddress)
            }
            return .success(BitcoinChainReceiveAddress<BitcoinToken>(address: address, label: label, onTxCompleted: onTxCompleted))
        case .coin(.bitcoinCash):
            let address = address.removing(prefix: "\(BitcoinCashURLPayload.scheme):")
            guard WalletCore.CoinType.bitcoinCash.validate(address: address) else {
                return .failure(.invalidAddress)
            }
            return .success(BitcoinChainReceiveAddress<BitcoinCashToken>(address: address, label: label, onTxCompleted: onTxCompleted))
        default:
            impossible()
        }
    }
}
