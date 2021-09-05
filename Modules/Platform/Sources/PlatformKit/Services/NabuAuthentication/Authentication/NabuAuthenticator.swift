// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import ToolKit

final class NabuAuthenticator: AuthenticatorAPI {

    // MARK: - Properties

    private var authenticationExecutor: NabuAuthenticationExecutorAPI {
        authenticationExecutorProvider()
    }

    private let authenticationExecutorProvider: NabuAuthenticationExecutorProvider

    // MARK: - Setup

    init(authenticationExecutorProvider: @escaping NabuAuthenticationExecutorProvider = resolve()) {
        self.authenticationExecutorProvider = authenticationExecutorProvider
    }

    // MARK: - AuthenticatorNewAPI

    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        authenticationExecutor.authenticate(networkResponsePublisher)
    }
}
