// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import stellarsdk

public class StellarKeyPairDeriver: KeyPairDeriverAPI {
    public typealias StellarWallet = stellarsdk.Wallet

    public func derive(input: StellarKeyDerivationInput) -> Result<StellarKeyPair, Error> {
        let keyPair: stellarsdk.KeyPair
        do {
            keyPair = try StellarWallet.createKeyPair(
                mnemonic: input.mnemonic,
                passphrase: input.passphrase,
                index: input.index
            )
        } catch {
            return .failure(error)
        }
        return .success(keyPair.toStellarKeyPair())
    }
}

extension stellarsdk.KeyPair {
    fileprivate func toStellarKeyPair() -> StellarKeyPair {
        StellarKeyPair(accountID: publicKey.accountId, secret: secretSeed)
    }
}
