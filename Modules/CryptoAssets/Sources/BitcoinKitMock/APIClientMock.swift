// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
@testable import BitcoinKit
import Foundation
import RxSwift

enum TestAPIClientError: Error {
    case testError
}

class APIClientMock: BitcoinKit.APIClientAPI {
    var underlyingMultiAddress: Single<BitcoinMultiAddressResponse> = .error(TestAPIClientError.testError)

    func multiAddress(for addresses: [XPub]) -> Single<BitcoinMultiAddressResponse> {
        underlyingMultiAddress
    }

    var underlyingBalances: Single<BitcoinBalanceResponse> = .error(TestAPIClientError.testError)

    func balances(for addresses: [XPub]) -> Single<BitcoinBalanceResponse> {
        underlyingBalances
    }

    var underlyingUnspentOutputs: Single<UnspentOutputsResponse> = .error(TestAPIClientError.testError)

    func unspentOutputs(for addresses: [XPub]) -> Single<UnspentOutputsResponse> {
        underlyingUnspentOutputs
    }
}
