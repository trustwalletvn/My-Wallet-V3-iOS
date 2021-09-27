// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureKYCDomain
import ToolKit

#if DEBUG
/// Intented for SwiftUI Previews and only available in DEBUG
class NoOpEmailVerificationService: EmailVerificationServiceAPI {

    func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationResponse, EmailVerificationCheckError> {
        Future { _ in
            // no-op
        }
        .eraseToAnyPublisher()
    }

    func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        Future { _ in
            // no-op
        }
        .eraseToAnyPublisher()
    }

    func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        Future { _ in
            // no-op
        }
        .eraseToAnyPublisher()
    }
}
#endif
