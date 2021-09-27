// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain

class MockLegacyPasswordProvider: LegacyPasswordProviding {
    var setLegacyPasswordCalled: (legacyPassword: String?, called: Bool) = (nil, false)

    func setLegacyPassword(_ legacyPassword: String?) {
        setLegacyPasswordCalled = (legacyPassword, true)
    }
}
