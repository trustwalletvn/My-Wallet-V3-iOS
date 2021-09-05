// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import DIKit
import InterestKit
import NetworkKit
import PlatformKit
import RxSwift

public final class InterestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI {

    private let client: InterestAccountBalanceClientAPI

    init(client: InterestAccountBalanceClientAPI = resolve()) {
        self.client = client
    }

    public func fetchInterestAccountBalanceStates(
        _ fiatCurrency: FiatCurrency)
        -> AnyPublisher<InterestAccountBalances, InterestAccountBalanceRepositoryError>
    {
        client
            .fetchBalanceWithFiatCurrency(fiatCurrency)
            .replaceNil(with: InterestAccountBalanceResponse.empty)
            .mapError(InterestAccountBalanceRepositoryError.networkError)
            .map(InterestAccountBalances.init)
            .eraseToAnyPublisher()
    }
}
