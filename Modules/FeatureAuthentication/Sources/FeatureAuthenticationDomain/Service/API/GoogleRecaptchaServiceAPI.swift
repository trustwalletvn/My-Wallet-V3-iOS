// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum GoogleRecaptchaError: Error, Equatable {
    case missingRecaptchaTokenError
    case rcaRecaptchaError(String)
    case unknownError
}

/// `GoogleRecaptchaServiceAPI` is the interface for using Google's Recaptcha Service
public protocol GoogleRecaptchaServiceAPI {
    /// Sends a recaptcha request for the login workflow
    /// - Returns: A combine `Publisher` that emits a Recaptcha Token on success or GoogleRecaptchaError on failure
    func verifyForLogin() -> AnyPublisher<String, GoogleRecaptchaError>
}
