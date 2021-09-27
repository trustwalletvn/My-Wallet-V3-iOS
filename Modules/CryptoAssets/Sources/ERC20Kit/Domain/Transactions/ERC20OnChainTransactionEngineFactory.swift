// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit

final class ERC20OnChainTransactionEngineFactory: OnChainTransactionEngineFactory {

    private let erc20Token: ERC20AssetModel

    init(erc20Token: ERC20AssetModel) {
        self.erc20Token = erc20Token
    }

    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine {
        ERC20OnChainTransactionEngine(
            erc20Token: erc20Token,
            requireSecondPassword: requiresSecondPassword
        )
    }
}
