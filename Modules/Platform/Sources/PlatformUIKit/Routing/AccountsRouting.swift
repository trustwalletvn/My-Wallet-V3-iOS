//
//  AccountsRouting.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol AccountsRouting: AnyObject {
    func route(to account: BlockchainAccount)
}
