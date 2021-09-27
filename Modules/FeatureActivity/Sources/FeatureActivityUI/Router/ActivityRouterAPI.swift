// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit

protocol ActivityRouterAPI: AnyObject {
    func showWalletSelectionScreen()
    func showTransactionScreen(with event: ActivityItemEvent)
    func showBlockchainExplorer(for event: TransactionalActivityItemEvent)
    func showActivityShareSheet(_ event: ActivityItemEvent)
}
