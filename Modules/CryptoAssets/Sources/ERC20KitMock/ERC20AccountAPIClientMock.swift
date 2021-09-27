// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20Kit
import RxSwift

final class ERC20AccountAPIClientMock: ERC20AccountAPIClientAPI {

    // MARK: - Private Properties

    private let fetchTransactionsResponse: Single<ERC20TransfersResponse> = .just(.transfersResponse)

    private let isContractResponse: Single<ERC20IsContractResponse> = .just(ERC20IsContractResponse(contract: false))

    // MARK: - Internal Methods

    func fetchTransactions(
        from address: String,
        page: String?,
        contractAddress: String
    ) -> Single<ERC20TransfersResponse> {
        fetchTransactionsResponse
    }

    func isContract(address: String) -> Single<ERC20IsContractResponse> {
        isContractResponse
    }
}
