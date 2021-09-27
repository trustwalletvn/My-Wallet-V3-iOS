// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct SwapOrder {
    let identifier: String
    let state: SwapActivityItemEvent.EventStatus
    let depositAddress: String?

    public init(
        identifier: String,
        state: SwapActivityItemEvent.EventStatus,
        depositAddress: String? = nil
    ) {
        self.identifier = identifier
        self.state = state
        self.depositAddress = depositAddress
    }
}
