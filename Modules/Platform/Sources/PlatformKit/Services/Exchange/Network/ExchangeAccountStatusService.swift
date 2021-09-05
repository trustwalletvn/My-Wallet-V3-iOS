// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountStatusServiceAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }
    var hasEnabled2FA: Single<Bool> { get }
}

public final class ExchangeAccountStatusService: ExchangeAccountStatusServiceAPI {

    // MARK: - ExchangeLinkStatusServiceAPI

    public var hasLinkedExchangeAccount: Single<Bool> {
        nabuUserService
            .user
            .map(\.hasLinkedExchangeAccount)
    }

    public var hasEnabled2FA: Single<Bool> {
        // It does not matter what asset we fetch.
        client.exchangeAddress(with: .coin(.bitcoin))
            // If the user has accounts returned,
            // then they have 2FA enabled.
            .map { _ in true }
            // If an error is thrown when fetching accounts
            // parse the error to determine if it is because 2FA is
            // not enabled.
            .catchError { error in
                guard let networkError = error as? NabuNetworkError else {
                    throw error
                }
                guard case .nabuError(let nabuError) = networkError else {
                    throw error
                }
                guard nabuError.code == .bad2fa else {
                    throw nabuError
                }
                return .just(false)
            }
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
