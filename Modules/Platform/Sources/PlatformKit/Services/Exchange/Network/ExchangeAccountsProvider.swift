// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol ExchangeAccountsProviderAPI {
    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount>
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

    func account(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount> {
        guard let account = storage.value[currency] else {
            Logger.shared.debug("Cache Miss: \(currency.code)")
            return fetchAccount(for: currency)
        }
        Logger.shared.debug("Cache Hit: \(currency.code)")
        return .just(account)
    }

    private func fetchAccount(for currency: CryptoCurrency) -> Single<CryptoExchangeAccount> {
        statusService.hasLinkedExchangeAccount
            .flatMap(weak: self) { (self, hasLinkedExchangeAccount) -> Single<CryptoExchangeAccount> in
                guard hasLinkedExchangeAccount else {
                    return .error(ExchangeAccountsNetworkError.missingAccount)
                }
                return self.client.exchangeAddress(with: currency)
                    .map { response in
                        CryptoExchangeAccount(response: response)
                    }
                    .do(onSuccess: { [weak self] account in
                        self?.storage.mutate { cache in
                            cache[currency] = account
                        }
                    })
                    .catchError { _ -> Single<CryptoExchangeAccount> in
                        Logger.shared.debug("Fetch Error: \(currency.code)")
                        throw ExchangeAccountsNetworkError.missingAccount
                    }
            }
    }
}
