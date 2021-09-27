// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

extension CacheConfiguration {

    /// Creates a cache configuration that flushes the cache on user login and logout.
    public static func onLoginLogout() -> CacheConfiguration {
        CacheConfiguration(flushNotificationNames: [.login, .logout])
    }
}
