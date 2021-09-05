// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain
import Foundation
import RxSwift

extension WalletPayloadClient.Response {
    static func fake(
        guid: String = "123-abc-456-def-789-ghi",
        authenticatorType: WalletAuthenticatorType = .standard,
        language: String = "en",
        serverTime: TimeInterval = Date().timeIntervalSince1970,
        payload: String? = "{\"pbkdf2_iterations\":1,\"version\":3,\"payload\":\"payload-for-wallet\"}",
        shouldSyncPubkeys: Bool = false
    ) -> WalletPayloadClient.Response {
        WalletPayloadClient.Response(
            guid: guid,
            authType: authenticatorType.rawValue,
            language: language,
            serverTime: serverTime,
            payload: payload,
            shouldSyncPubkeys: shouldSyncPubkeys
        )
    }
}
