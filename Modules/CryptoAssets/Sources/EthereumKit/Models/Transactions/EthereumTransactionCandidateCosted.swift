// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import WalletCore

public struct EthereumTransactionCandidateCosted {
    let transaction: EthereumSigningInput

    init(transaction: EthereumTransactionCandidate, nonce: BigUInt) throws {
        guard transaction.gasPrice > 0 else {
            throw EthereumKitValidationError.noGasPrice
        }
        guard transaction.gasLimit > 0 else {
            throw EthereumKitValidationError.noGasLimit
        }
        self.transaction = Self.signingInput(with: transaction, nonce: nonce)
    }

    private static func signingInput(
        with candidate: EthereumTransactionCandidate,
        nonce: BigUInt
    ) -> EthereumSigningInput {
        EthereumSigningInput.with {
            $0.chainID = Data(hexString: "01")!
            $0.nonce = Data(hexString: nonce.hexString)!
            $0.gasPrice = Data(hexString: candidate.gasPrice.hexString)!
            $0.gasLimit = Data(hexString: candidate.gasLimit.hexString)!
            switch candidate.transferType {
            case .erc20Transfer(let contractAddress):
                $0.toAddress = contractAddress.publicKey
                $0.transaction.erc20Transfer.to = candidate.to.publicKey
                $0.transaction.erc20Transfer.amount = Data(hexString: candidate.value.hexString)!
            case .transfer:
                $0.toAddress = candidate.to.publicKey
                $0.transaction.transfer.amount = Data(hexString: candidate.value.hexString)!
                $0.transaction.transfer.data = candidate.data ?? Data()
            }
        }
    }
}
