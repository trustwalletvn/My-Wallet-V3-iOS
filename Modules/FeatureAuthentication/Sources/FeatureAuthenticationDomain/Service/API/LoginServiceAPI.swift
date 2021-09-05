// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

/// A potential login service error
public enum LoginServiceError: LocalizedError {

    /// A 2FA required in order to complete the login
    case twoFactorOTPRequired(WalletAuthenticatorType)

    /// Other 2FA related errors
    case twoFAWalletServiceError(TwoFAWalletServiceError)

    /// Other Wallet Payload related errors
    case walletPayloadServiceError(WalletPayloadServiceError)
}

/// Service that provides login methods
public protocol LoginServiceAPI: AnyObject {
    var authenticator: AnyPublisher<WalletAuthenticatorType, Never> { get }

    /// Standard login using cached `GUID` and `session-token`
    func login(walletIdentifier: String) -> AnyPublisher<Void, LoginServiceError>

    /// 2FA login using using cached `GUID` and `session-token`,
    /// and an OTP (from an authenticator app)
    func login(walletIdentifier: String, code: String) -> AnyPublisher<Void, LoginServiceError>
}
