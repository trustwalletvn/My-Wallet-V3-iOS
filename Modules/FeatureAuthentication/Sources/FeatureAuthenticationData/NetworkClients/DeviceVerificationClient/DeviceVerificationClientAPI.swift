// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

protocol DeviceVerificationClientAPI {
    func sendGuidReminder(
        sessionToken: String,
        emailAddress: String,
        captcha: String
    ) -> AnyPublisher<
        Void,
        NetworkError
    >

    func authorizeApprove(
        sessionToken: String,
        emailCode: String
    ) -> AnyPublisher<
        AuthorizeApproveResponse,
        NetworkError
    >
}
