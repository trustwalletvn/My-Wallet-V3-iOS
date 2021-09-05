// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import NetworkKit
import RxSwift

public enum EmailSettingsServiceError: Error {
    case credentialsError(MissingCredentialsError)
    case networkError(NetworkError)
}

public protocol EmailSettingsServiceAPI: AnyObject {

    /// A `Single` that streams
    var email: Single<String> { get }

    /// Updates the email associated with the wallet
    /// - Parameter email: The new email address
    /// - Parameter context: The context in which the request has happened
    /// - Returns: A `Completable`
    func update(email: String, context: FlowContext?) -> Completable

    func update(email: String) -> AnyPublisher<String, EmailSettingsServiceError>
}
