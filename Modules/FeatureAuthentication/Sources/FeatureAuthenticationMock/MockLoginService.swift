// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain

final class MockLoginService: LoginServiceAPI {

    /// Change these to adjust the mock service behaviour
    var twoFAType: WalletAuthenticatorType = .standard
    var twoFAServiceError: LoginServiceError?

    var authenticator: AnyPublisher<WalletAuthenticatorType, Never> = .just(.standard)

    func login(walletIdentifier: String) -> AnyPublisher<Void, LoginServiceError> {
        switch twoFAType {
        case .standard:
            return .just(())
        case .yubiKey:
            return .failure(.twoFactorOTPRequired(.yubiKey))
        case .email:
            return .failure(.twoFactorOTPRequired(.email))
        case .yubikeyMtGox:
            return .failure(.twoFactorOTPRequired(.yubikeyMtGox))
        case .google:
            return .failure(.twoFactorOTPRequired(.google))
        case .sms:
            return .failure(.twoFactorOTPRequired(.sms))
        }
    }

    func login(walletIdentifier: String, code: String) -> AnyPublisher<Void, LoginServiceError> {
        if let error = twoFAServiceError {
            return .failure(error)
        }
        return .just(())
    }
}
