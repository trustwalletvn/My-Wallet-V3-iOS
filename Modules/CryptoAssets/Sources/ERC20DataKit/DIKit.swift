// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ERC20Kit

extension DependencyContainer {

    // MARK: - ERC20DataKit Module

    public static var erc20DataKit = module {

        factory { ERC20AccountClient() as ERC20AccountClientAPINew }

        single { ERC20TokenAccountsRepository() as ERC20TokenAccountsRepositoryAPI }
    }
}
