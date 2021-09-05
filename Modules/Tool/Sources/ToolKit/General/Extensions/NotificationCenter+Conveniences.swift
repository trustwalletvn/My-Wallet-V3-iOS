// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension NotificationCenter {
    @discardableResult public static func when(
        _ name: NSNotification.Name,
        action: @escaping (Notification) -> Void
    ) -> NSObjectProtocol {
        NotificationCenter.default.when(name, action: action)
    }

    @discardableResult public func when(
        _ name: NSNotification.Name,
        action: @escaping (Notification) -> Void
    ) -> NSObjectProtocol {
        addObserver(
            forName: name,
            object: nil,
            queue: .main,
            using: action
        )
    }
}
