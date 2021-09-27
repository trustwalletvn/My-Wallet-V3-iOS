// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkKit

/// A potential SMS service error
public enum SMSServiceError: LocalizedError, Equatable {

    /// missing credentials
    case missingCredentials(MissingCredentialsError)

    /// other network errors
    case networkError(NetworkError)
}

public protocol SMSServiceAPI: AnyObject {
    /// Requests SMS OTP
    func request() -> AnyPublisher<Void, SMSServiceError>
}
