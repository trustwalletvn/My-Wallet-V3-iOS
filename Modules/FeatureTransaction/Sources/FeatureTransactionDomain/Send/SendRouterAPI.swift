// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol SendRouterAPI {
    func send(account: BlockchainAccount)
}
