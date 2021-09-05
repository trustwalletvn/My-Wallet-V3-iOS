// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import WalletCore

public typealias AnyEthereumKeyPairDeriver = AnyKeyPairDeriver<EthereumKeyPair, EthereumKeyDerivationInput, HDWalletError>

public struct EthereumKeyPairDeriver: KeyPairDeriverAPI {

    public func derive(input: EthereumKeyDerivationInput) -> Result<EthereumKeyPair, HDWalletError> {
        let ethereumCoinType = CoinType.ethereum
        // Hardcoding BIP39 passphrase as empty string as it is currently not  supported.
        guard let hdWallet = HDWallet(mnemonic: input.mnemonic, passphrase: "") else {
            return .failure(.walletFailedToInitialise())
        }
        let privateKey = hdWallet.getKeyForCoin(coin: ethereumCoinType)
        let publicKey = hdWallet.getAddressForCoin(coin: ethereumCoinType)
        let ethereumPrivateKey = EthereumPrivateKey(
            mnemonic: input.mnemonic,
            data: privateKey.data
        )
        let keyPair = EthereumKeyPair(
            accountID: publicKey,
            privateKey: ethereumPrivateKey
        )
        return .success(keyPair)
    }
}
