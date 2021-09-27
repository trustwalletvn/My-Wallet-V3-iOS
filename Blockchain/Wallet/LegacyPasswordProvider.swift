// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Foundation

class LegacyPasswordProvider: LegacyPasswordProviding {
    func setLegacyPassword(_ legacyPassword: String?) {
        WalletManager.shared.legacyRepository.legacyPassword = legacyPassword
    }
}
