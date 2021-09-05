// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

class MockSiftService: SiftServiceAPI {

    var enableCalled = false

    func enable() {
        enableCalled = true
    }

    var setUserIdCalled: (Bool, String?) = (false, nil)

    func set(userId: String) {
        setUserIdCalled = (true, userId)
    }

    var removeUserIdCalled = false

    func removeUserId() {
        removeUserIdCalled = true
    }
}
