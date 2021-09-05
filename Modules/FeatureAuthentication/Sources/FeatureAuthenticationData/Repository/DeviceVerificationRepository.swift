// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain

final class DeviceVerificationRepository: DeviceVerificationRepositoryAPI {

    // MARK: - Properties

    private let apiClient: DeviceVerificationClientAPI

    // MARK: - Setup

    init(apiClient: DeviceVerificationClientAPI = resolve()) {
        self.apiClient = apiClient
    }

    // MARK: - DeviceVerificationRepositoryAPI

    func sendDeviceVerificationEmail(
        sessionToken: String,
        to emailAddress: String,
        captcha: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        apiClient
            .sendGuidReminder(sessionToken: sessionToken, emailAddress: emailAddress, captcha: captcha)
            .mapError(DeviceVerificationServiceError.networkError)
            .eraseToAnyPublisher()
    }

    func authorizeLogin(
        sessionToken: String,
        emailCode: String
    ) -> AnyPublisher<
        Void,
        DeviceVerificationServiceError
    > {
        apiClient
            .authorizeApprove(sessionToken: sessionToken, emailCode: emailCode)
            .mapError(DeviceVerificationServiceError.networkError)
            .flatMap { response -> AnyPublisher<Void, DeviceVerificationServiceError> in
                // We still need to parse the payload in order to detect
                // failures or successes
                guard response.success else {
                    guard let error = response.error,
                          !error.isEmpty
                    else {
                        return .failure(.networkError(.payloadError(.emptyData)))
                    }
                    // Since this API doesn't return specific error codes
                    // we send a specific error case
                    return .failure(.expiredEmailCode)
                }
                return .just(())
            }
            .eraseToAnyPublisher()
    }
}
