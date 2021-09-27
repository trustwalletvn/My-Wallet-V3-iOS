// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Foundation
import PlatformKit

struct KeychainItemSwiftWrapper: KeychainItemWrapping {

    func pinFromKeychain() -> String? {
        KeychainItemWrapper.pinFromKeychain()
    }

    func removePinFromKeychain() {
        KeychainItemWrapper.removePinFromKeychain()
    }

    func setPINInKeychain(_ pin: String?) {
        KeychainItemWrapper.setPINInKeychain(pin)
    }

    func guid() -> String? {
        KeychainItemWrapper.guid()
    }

    func removeGuidFromKeychain() {
        KeychainItemWrapper.removeGuidFromKeychain()
    }

    func setGuidInKeychain(_ guid: String?) {
        KeychainItemWrapper.setGuidInKeychain(guid)
    }

    func sharedKey() -> String? {
        KeychainItemWrapper.sharedKey()
    }

    func removeSharedKeyFromKeychain() {
        KeychainItemWrapper.removeSharedKeyFromKeychain()
    }

    func setSharedKeyInKeychain(_ sharedKey: String?) {
        KeychainItemWrapper.setSharedKeyInKeychain(sharedKey)
    }

    func removeAllSwipeAddresses() {
        KeychainItemWrapper.removeAllSwipeAddresses()
    }
}
