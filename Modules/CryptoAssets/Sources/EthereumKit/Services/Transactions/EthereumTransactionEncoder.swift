// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

public enum EthereumTransactionEncoderError: Error {
    case encodingError
}

public protocol EthereumTransactionEncoderAPI {
    func encode(signed: EthereumTransactionCandidateSigned) -> Result<EthereumTransactionFinalised, EthereumTransactionEncoderError>
}

public struct EthereumTransactionEncoder: EthereumTransactionEncoderAPI {
    public func encode(signed: EthereumTransactionCandidateSigned) -> Result<EthereumTransactionFinalised, EthereumTransactionEncoderError> {

        .success(
            EthereumTransactionFinalised(
                transaction: signed
            )
        )
    }
}
