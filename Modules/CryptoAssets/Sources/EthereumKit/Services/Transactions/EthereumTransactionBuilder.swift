// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import RxSwift
import ToolKit

public enum EthereumKitValidationError: TransactionValidationError {
    case noGasPrice
    case noGasLimit
    case unknown
}

protocol EthereumTransactionBuilderAPI {

    func build(transaction: EthereumTransactionCandidate, nonce: BigUInt) -> Result<EthereumTransactionCandidateCosted, EthereumKitValidationError>
}

final class EthereumTransactionBuilder: EthereumTransactionBuilderAPI {

    func build(transaction: EthereumTransactionCandidate, nonce: BigUInt) -> Result<EthereumTransactionCandidateCosted, EthereumKitValidationError> {
        do {
            let candidate = try EthereumTransactionCandidateCosted(transaction: transaction, nonce: nonce)
            return .success(candidate)
        } catch let error as EthereumKitValidationError {
            return .failure(error)
        } catch {
            return .failure(.unknown)
        }
    }
}
