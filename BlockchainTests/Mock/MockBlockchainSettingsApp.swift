// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import SettingsKit

final class MockBlockchainSettingsApp: BlockchainSettingsAppAPI {
    internal init(
        biometryEnabled: Bool = false,
        browserIdentities: String? = nil,
        cloudBackupEnabled: Bool = true,
        deviceKey: String? = nil,
        didRequestCameraPermissions: Bool = false,
        didRequestMicrophonePermissions: Bool = false,
        didRequestNotificationPermissions: Bool = false,
        encryptedPinPassword: String? = nil,
        guid: String? = nil,
        isPairedWithWallet: Bool = false,
        isPinSet: Bool = false,
        onSymbolLocalChanged: ((Bool) -> Void)? = nil,
        passwordPartHash: String? = nil,
        pin: String? = nil,
        pinKey: String? = nil,
        sharedKey: String? = nil,
        symbolLocal: Bool = false,
        clearPinCalled: Bool = false,
        resetCalled: Bool = false
    ) {
        self.biometryEnabled = biometryEnabled
        self.browserIdentities = browserIdentities
        self.cloudBackupEnabled = cloudBackupEnabled
        self.deviceKey = deviceKey
        self.didRequestCameraPermissions = didRequestCameraPermissions
        self.didRequestMicrophonePermissions = didRequestMicrophonePermissions
        self.didRequestNotificationPermissions = didRequestNotificationPermissions
        self.encryptedPinPassword = encryptedPinPassword
        self.guid = guid
        self.isPairedWithWallet = isPairedWithWallet
        self.isPinSet = isPinSet
        self.onSymbolLocalChanged = onSymbolLocalChanged
        self.passwordPartHash = passwordPartHash
        self.pin = pin
        self.pinKey = pinKey
        self.sharedKey = sharedKey
        self.symbolLocal = symbolLocal
        self.clearPinCalled = clearPinCalled
        self.resetCalled = resetCalled
    }

    // MARK: BlockchainSettingsAppAPI

    var biometryEnabled: Bool = false
    var browserIdentities: String?
    var cloudBackupEnabled: Bool = true
    var deviceKey: String?
    var didRequestCameraPermissions: Bool = false
    var didRequestMicrophonePermissions: Bool = false
    var didRequestNotificationPermissions: Bool = false
    var encryptedPinPassword: String?
    var guid: String?
    var isPairedWithWallet: Bool = false
    var isPinSet: Bool = false
    var onSymbolLocalChanged: ((Bool) -> Void)?
    var passwordPartHash: String?
    var pin: String?
    var pinKey: String?
    var sharedKey: String?
    var symbolLocal: Bool = false {
        didSet {
            if oldValue != symbolLocal {
                onSymbolLocalChanged?(symbolLocal)
            }
        }
    }

    func clearPin() {
        clearPinCalled = true
    }

    func reset() {
        resetCalled = true
    }

    // MARK: Mock Supporting

    var clearPinCalled: Bool = false
    var resetCalled: Bool = false
}
