// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public protocol EthereumFeeServiceAPI {
    func fees(cryptoCurrency: CryptoCurrency) -> Single<EthereumTransactionFee>
}

final class EthereumFeeService: EthereumFeeServiceAPI {

    // MARK: - CryptoFeeServiceAPI

    func fees(cryptoCurrency: CryptoCurrency) -> Single<EthereumTransactionFee> {
        client
            .fees(cryptoCurrency: cryptoCurrency)
            .map { response in
                EthereumTransactionFee(
                    limits: response.limits,
                    regular: response.regular,
                    priority: response.priority,
                    gasLimit: response.gasLimit,
                    gasLimitContract: response.gasLimitContract
                )
            }
            .catchErrorJustReturn(.default)
    }

    // MARK: - Private Properties

    private let client: TransactionFeeClientAPI

    // MARK: - Init

    init(client: TransactionFeeClientAPI = resolve()) {
        self.client = client
    }
}
