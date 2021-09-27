// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

final class StellarOnChainTransactionEngineFactory: OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        StellarOnChainTransactionEngine(requireSecondPassword: requiresSecondPassword)
    }
}
