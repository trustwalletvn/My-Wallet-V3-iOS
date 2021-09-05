// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import Foundation
import ToolKit

protocol NetworkCommunicatorAPI {

    /// Performs network requests
    /// - Parameter request: the request object describes the network request to be performed
    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>
}

final class NetworkCommunicator: NetworkCommunicatorAPI {

    // MARK: - Private properties

    private let session: NetworkSession
    private let authenticator: AuthenticatorAPI?
    private let eventRecorder: AnalyticsEventRecorderAPI?

    // MARK: - Setup

    init(
        session: NetworkSession = resolve(),
        sessionDelegate: SessionDelegateAPI = resolve(),
        sessionHandler: NetworkSessionDelegateAPI = resolve(),
        authenticator: AuthenticatorAPI? = nil,
        eventRecorder: AnalyticsEventRecorderAPI? = nil
    ) {
        self.session = session
        self.authenticator = authenticator
        self.eventRecorder = eventRecorder

        sessionDelegate.delegate = sessionHandler
    }

    // MARK: - Internal methods

    func dataTaskPublisher(
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        guard request.authenticated else {
            return execute(request: request)
        }
        guard let authenticator = authenticator else {
            fatalError("Authenticator missing")
        }
        let execute = self.execute
        return authenticator
            .authenticate { [execute] token in
                execute(request.adding(authenticationToken: token))
            }
    }

    // MARK: - Private methods

    private func execute(
        request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        if request.shouldDebug {
            Logger.shared.debug("[NetworkKit] Performing request: \(request)")
        }
        return session.erasedDataTaskPublisher(for: request.urlRequest)
            .mapError(NetworkError.urlError)
            .flatMap { elements -> AnyPublisher<ServerResponse, NetworkError> in
                request.responseHandler.handle(elements: elements, for: request)
            }
            .eraseToAnyPublisher()
            .recordErrors(on: eventRecorder, request: request) { request, error -> AnalyticsEvent? in
                error.analyticsEvent(for: request) { serverErrorResponse in
                    request.decoder.decodeFailureToString(errorResponse: serverErrorResponse)
                }
            }
            .eraseToAnyPublisher()
    }
}

protocol NetworkSession {

    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

extension URLSession: NetworkSession {

    func erasedDataTaskPublisher(
        for request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
    Failure == NetworkError
{

    fileprivate func recordErrors(
        on recorder: AnalyticsEventRecorderAPI?,
        request: NetworkRequest,
        errorMapper: @escaping (NetworkRequest, NetworkError) -> AnalyticsEvent?
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        handleEvents(
            receiveCompletion: { completion in
                guard case .failure(let communicatorError) = completion else {
                    return
                }
                guard let event = errorMapper(request, communicatorError) else {
                    return
                }
                recorder?.record(event: event)
            }
        )
        .eraseToAnyPublisher()
    }
}
