// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import EthereumKit
import PlatformKit
import RxSwift

class EthereumKeyPairDeriverMock: KeyPairDeriverAPI {
    var deriveResult: Result<EthereumKeyPair, HDWalletError> = .success(
        MockEthereumWalletTestData.keyPair
    )
    var lastMnemonic: String?

    func derive(input: EthereumKeyDerivationInput) -> Result<EthereumKeyPair, HDWalletError> {
        lastMnemonic = input.mnemonic
        return deriveResult
    }
}
