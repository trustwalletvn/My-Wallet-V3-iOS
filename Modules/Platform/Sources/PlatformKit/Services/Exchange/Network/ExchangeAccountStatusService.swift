// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import RxSwift
import ToolKit

public enum ExchangeAccountStatusServiceError: Error {
    case unknown(Error)
    case network(NabuNetworkError)
}

public protocol ExchangeAccountStatusServiceAPI {

    var hasLinkedExchangeAccount: AnyPublisher<Bool, ExchangeAccountStatusServiceError> { get }

    var hasEnabled2FA: AnyPublisher<Bool, NabuNetworkError> { get }
}

public final class ExchangeAccountStatusService: ExchangeAccountStatusServiceAPI {

    // MARK: - ExchangeLinkStatusServiceAPI

    public var hasLinkedExchangeAccount: AnyPublisher<Bool, ExchangeAccountStatusServiceError> {
        nabuUserService.user
            .asPublisher()
            .mapError(ExchangeAccountStatusServiceError.unknown)
            .map(\.hasLinkedExchangeAccount)
            .eraseToAnyPublisher()
    }

    public var hasEnabled2FA: AnyPublisher<Bool, NabuNetworkError> {
        // It does not matter what asset we fetch.
        client.exchangeAddress(with: .coin(.bitcoin))
            // If the user has accounts returned,
            // then they have 2FA enabled.
            .map { _ in true }
            // If an error is thrown when fetching accounts
            // parse the error to determine if it is because 2FA is
            // not enabled.
            .catch { networkError -> AnyPublisher<Bool, NabuNetworkError> in
                guard case .nabuError(let nabuError) = networkError else {
                    return .failure(networkError)
                }
                guard nabuError.code == .bad2fa else {
                    return .failure(networkError)
                }
                return .just(false)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    private let nabuUserService: NabuUserServiceAPI
    private let client: ExchangeAccountsProviderClientAPI

    // MARK: - Init

    init(
        nabuUserService: NabuUserServiceAPI = resolve(),
        client: ExchangeAccountsClientAPI = resolve()
    ) {
        self.nabuUserService = nabuUserService
        self.client = client
    }
}
