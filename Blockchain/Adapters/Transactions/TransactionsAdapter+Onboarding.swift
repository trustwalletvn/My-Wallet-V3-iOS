// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI
import UIKit

extension TransactionsAdapter: FeatureOnboardingUI.BuyCryptoRouterAPI {

    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        presentTransactionFlow(to: .buy(nil), from: presenter)
            .map(OnboardingResult.init)
            .eraseToAnyPublisher()
    }
}

extension OnboardingResult {

    init(_ transactionResult: TransactionResult) {
        switch transactionResult {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}
