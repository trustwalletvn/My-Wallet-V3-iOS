// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain

extension DependencyContainer {

    // MARK: - FeatureTransactionUI Module

    public static var featureTransactionUI = module {

        factory { ReceiveCoordinator() }

        // MARK: - Receive

        factory { ReceiveRouter() as ReceiveRouterAPI }

        // MARK: - Hooks

        factory { TransactionAnalyticsHook() }

        // MARK: - Other

        factory { TransactionsRouter() as TransactionsRouterAPI }
    }
}
