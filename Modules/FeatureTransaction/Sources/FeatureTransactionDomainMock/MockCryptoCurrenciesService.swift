// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureTransactionDomain
import PlatformKit
import ToolKit

final class MockCryptoCurrenciesService: CryptoCurrenciesServiceAPI {

    struct RecordedInvocations {
        var fetchPurchasableCryptoCurrencies: [FiatCurrency] = []
    }

    struct StubbedResults {
        var fetchPurchasableCryptoCurrencies: AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError> = .just([])
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func fetchPurchasableCryptoCurrencies(
        using fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError> {
        recordedInvocations.fetchPurchasableCryptoCurrencies.append(fiatCurrency)
        return stubbedResults.fetchPurchasableCryptoCurrencies
    }
}
