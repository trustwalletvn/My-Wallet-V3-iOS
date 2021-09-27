// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import PlatformKit
import RxSwift

class BalanceClientAPIMock: BalanceClientAPI {
    var balanceDetailsValue: Single<BalanceDetailsResponse> = .error(EthereumAPIClientMockError.mockError)

    func balanceDetails(from address: String) -> Single<BalanceDetailsResponse> {
        balanceDetailsValue
    }
}
