// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import XCTest

struct MockNabuUserSunriverAirdropRegistered: NabuUserSunriverAirdropRegistering {
    let isSunriverAirdropRegistered: Bool

    init(isRegistered: Bool) {
        isSunriverAirdropRegistered = isRegistered
    }
}
