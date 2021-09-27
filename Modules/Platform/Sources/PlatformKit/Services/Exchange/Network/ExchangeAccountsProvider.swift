// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountsProviderAPI {

    func account(
        for currency: CryptoCurrency
    ) -> AnyPublisher<CryptoExchangeAccount, ExchangeAccountsNetworkError>
}

final class ExchangeAccountsProvider: ExchangeAccountsProviderAPI {

    // MARK: - Private Properties

    private let statusService: ExchangeAccountStatusServiceAPI
    private let client: ExchangeAccountsProviderClientAPI
    private let disposeBag = DisposeBag()
    private let storage: Atomic<[CryptoCurrency: CryptoExchangeAccount]> = .init([:])

    // MARK: - Init

    init(
        client: ExchangeAccountsClientAPI = resolve(),
        statusService: ExchangeAccountStatusServiceAPI = resolve()
    ) {
        self.statusService = statusService
        self.client = client

        NotificationCenter.when(.login) { [weak self] _ in
            guard let self = self else { return }
            self.storage.mutate { cache in
                cache.removeAll()
            }
        }
        NotificationCenter.when(.logout) { [weak self] _ in
            guard let self = self else { return }
            self.storage.mutate { cache in
                cache.removeAll()
            }
        }
    }

    // MARK: - ExchangeAccountsProviderAPI

    func account(
        for currency: CryptoCurrency
    ) -> AnyPublisher<CryptoExchangeAccount, ExchangeAccountsNetworkError> {
        guard let account = storage.value[currency] else {
            Logger.shared.debug("Cache Miss: \(currency.code)")
            return fetchAccount(for: currency)
        }
        Logger.shared.debug("Cache Hit: \(currency.code)")
        return .just(account)
    }

    // MARK: - Private methods

    private func fetchAccount(
        for currency: CryptoCurrency
    ) -> AnyPublisher<CryptoExchangeAccount, ExchangeAccountsNetworkError> {
        statusService.hasLinkedExchangeAccount
            .replaceError(with: ExchangeAccountsNetworkError.missingAccount)
            .flatMap { [client, storage] hasLinkedExchangeAccount
                -> AnyPublisher<CryptoExchangeAccount, ExchangeAccountsNetworkError> in
                guard hasLinkedExchangeAccount else {
                    return .failure(.missingAccount)
                }
                return client.exchangeAddress(with: currency)
                    .map(CryptoExchangeAccount.from)
                    .handleEvents(receiveOutput: { account in
                        storage.mutate { cache in
                            cache[currency] = account
                        }
                    })
                    .replaceError(with: ExchangeAccountsNetworkError.missingAccount)
            }
            .eraseToAnyPublisher()
    }
}
