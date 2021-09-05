// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum WalletAuthenticationType: Equatable {

    /// Standard auth using guid (wallet identifier) and password
    case standard

    /// Special auth using guid (wallet identifier), password and one time 2FA string
    case twoFA(String)
}

/// Any action related to authentication should go here
public enum WalletAuthenticationAction {

    /// Authorize login by approving a message sent by email
    case authorizeLoginWithEmail

    /// Authorize login by inserting an OTP code
    case authorizeLoginWith2FA(WalletAuthenticatorType)

    /// Wrong OTP code
    case wrongOtpCode(type: WalletAuthenticatorType, attemptsLeft: Int)

    /// Account is locked
    case lockedAccount

    /// Some error that should be reflected to the user
    case message(String)

    case error(Error)
}
