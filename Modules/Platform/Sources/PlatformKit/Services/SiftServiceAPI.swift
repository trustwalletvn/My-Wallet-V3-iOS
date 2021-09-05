// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol SiftServiceAPI {
    func enable()
    func set(userId: String)
    func removeUserId()
}
