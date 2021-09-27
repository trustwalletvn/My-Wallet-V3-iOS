// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol ERC20AccountAPIClientAPI {

    func fetchTransactions(
        from address: String,
        page: String?,
        contractAddress: String
    ) -> Single<ERC20TransfersResponse>

    func isContract(address: String) -> Single<ERC20IsContractResponse>
}
