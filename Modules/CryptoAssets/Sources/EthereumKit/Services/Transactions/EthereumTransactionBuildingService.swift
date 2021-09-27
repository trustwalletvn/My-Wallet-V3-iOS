// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import FeatureTransactionDomain
import Foundation
import PlatformKit
import RxSwift

public protocol EthereumTransactionBuildingServiceAPI {
    func buildTransaction(
        amount: MoneyValue,
        to address: EthereumAddress,
        feeLevel: FeeLevel,
        fee: EthereumTransactionFee,
        contractAddress: EthereumAddress?
    ) -> Single<EthereumTransactionCandidate>
}

final class EthereumTransactionBuildingService: EthereumTransactionBuildingServiceAPI {

    func buildTransaction(
        amount: MoneyValue,
        to address: EthereumAddress,
        feeLevel: FeeLevel,
        fee: EthereumTransactionFee,
        contractAddress: EthereumAddress?
    ) -> Single<EthereumTransactionCandidate> {
        let isContract = contractAddress != nil
        let candidate = EthereumTransactionCandidate(
            to: address,
            gasPrice: BigUInt(fee.fee(feeLevel: feeLevel.ethereumFeeLevel).amount),
            gasLimit: BigUInt(isContract ? fee.gasLimitContract : fee.gasLimit),
            value: BigUInt(amount.amount),
            data: Data(),
            transferType: isContract ? .erc20Transfer(contract: contractAddress!) : .transfer
        )
        return .just(candidate)
    }
}

extension FeeLevel {
    public var ethereumFeeLevel: EthereumTransactionFee.FeeLevel {
        switch self {
        case .custom, .none, .regular:
            return .regular
        case .priority:
            return .priority
        }
    }
}
