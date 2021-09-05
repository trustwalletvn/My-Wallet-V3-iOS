// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import InterestKit
import PlatformKit
import ToolKit

public final class InterestAccountLimitsRepository: InterestAccountLimitsRepositoryAPI {

    // MARK: - Private Properties

    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let client: InterestAccountLimitsClientAPI

    // MARK: - Init

    init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        client: InterestAccountLimitsClientAPI = resolve()
    ) {
        self.enabledCurrenciesService = enabledCurrenciesService
        self.client = client
    }

    // MARK: - InterestAccountLimitsRepositoryAPI

    public func fetchInterestAccountLimitsForAllAssets(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[InterestAccountLimits], InterestAccountLimitsError> {
        let enabledCryptoCurrencies = enabledCurrenciesService
            .allEnabledCryptoCurrencies
        return client
            .fetchInterestAccountLimitsResponseForFiatCurrency(fiatCurrency)
            .mapError(InterestAccountLimitsError.networkError)
            .map { response -> [InterestAccountLimits] in
                enabledCryptoCurrencies
                    .compactMap { crypto -> InterestAccountLimits? in
                        guard let value = response[crypto] else { return nil }
                        return InterestAccountLimits(
                            value,
                            cryptoCurrency: crypto
                        )
                    }
            }
            .eraseToAnyPublisher()
    }

    public func fetchInterestAccountLimitsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountLimits, InterestAccountLimitsError> {
        fetchInterestAccountLimitsForAllAssets(fiatCurrency)
            .tryMap { interestAccountLimits -> InterestAccountLimits in
                let limit = interestAccountLimits
                    .first(where: { $0.cryptoCurrency == cryptoCurrency })
                guard let limit = limit else {
                    throw InterestAccountLimitsError.interestAccountLimitsUnavailable
                }
                return limit
            }
            .mapError(InterestAccountLimitsError.networkError)
            .eraseToAnyPublisher()
    }
}
