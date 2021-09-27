// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import ToolKit

extension UserDefaults {
    enum Keys: String {
        case didRequestCameraPermissions
        case didRequestMicrophonePermissions
        case didRequestNotificationPermissions
        case encryptedPinPassword
        /// legacyEncryptedPinPassword is required for wallets that created a PIN prior to Homebrew release - see IOS-1537
        case legacyEncryptedPinPassword = "encryptedPINPassword"
        case hasEndedFirstSession
        case pinKey
        case symbolLocal
        case passwordPartHash
        case biometryEnabled
        case cloudBackupEnabled
        case defaultAccountLabelledAddressesCount
        case didTapOnAirdropDeepLink
        case didAttemptToRouteForAirdrop
        case exchangeLinkIdentifier = "pitLinkIdentifier"
        case didTapOnExchangeDeepLink = "didTapOnPitDeepLink"
        case custodySendInterstitialViewed
        case pin
        case password
        case secureChannelDeviceKey
        case secureChannelBrowserIdentities
    }
}

extension CacheSuite {
    func migrateLegacyKeysIfNeeded() {
        migrateBool(fromKey: "touchIDEnabled", toKey: UserDefaults.Keys.biometryEnabled.rawValue)
    }

    private func migrateBool(fromKey: String, toKey: String) {
        guard let value = object(forKey: fromKey) as? Bool else { return }
        set(value, forKey: toKey)
        removeObject(forKey: fromKey)
    }
}
