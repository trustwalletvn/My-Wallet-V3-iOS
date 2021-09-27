// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import ERC20DataKit
import NetworkKit
import PlatformKit

final class ERC20AccountClientNewMock: ERC20AccountClientAPINew {

    // MARK: - Private Properties

    private let tokenAccountsResponse: ERC20TokenAccountsResponse

    private let errorAddress: String

    // MARK: - Setup

    /// Creates a mock ERC-20 account client
    ///
    /// - Parameters:
    ///   - cryptoCurrency: An ERC-20 crypto currency.
    ///   - errorAddress:   An error address.
    init(cryptoCurrency: CryptoCurrency, errorAddress: String) {
        tokenAccountsResponse = .stubbed(cryptoCurrency: cryptoCurrency)
        self.errorAddress = errorAddress
    }

    // MARK: - Internal Methods

    func tokens(for address: String) -> AnyPublisher<ERC20TokenAccountsResponse, NetworkError> {
        switch address {
        case errorAddress:
            return .failure(.payloadError(.emptyData))
        default:
            return .just(tokenAccountsResponse)
        }
    }
}
