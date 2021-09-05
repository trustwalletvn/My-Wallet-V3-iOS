// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit
import WalletPayloadKit

public final class TwoFAWalletClient: TwoFAWalletClientAPI {

    /// Potential errors.
    /// Possiblly there are more than one error, but only one is known
    /// at the moment.
    public enum ClientError: Error {

        private enum RawErrorSubstring {
            static let accountLocked = "locked"
            static let wrongCode = "attempts left"
        }

        /// Wrong code
        case wrongCode(attemptsLeft: Int)

        // Account locked
        case accountLocked

        case networkError(NetworkError)

        /// Initialized with plain server error
        init?(plainServerError: String) {
            if plainServerError.contains(RawErrorSubstring.accountLocked) {
                self = .accountLocked
            } else if plainServerError.contains(RawErrorSubstring.wrongCode) {
                let attemptsLeftString = plainServerError.components(
                    separatedBy: CharacterSet.decimalDigits.inverted
                )
                .joined()
                guard let attemptsLeft = Int(attemptsLeftString) else {
                    return nil
                }
                self = .wrongCode(attemptsLeft: attemptsLeft)
            } else {
                return nil
            }
        }
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: TwoFARequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = TwoFARequestBuilder(requestBuilder: requestBuilder)
    }

    // MARK: - API

    public func payload(
        guid: String,
        sessionToken: String,
        code: String
    ) -> AnyPublisher<WalletPayloadWrapper, ClientError> {
        let request = requestBuilder.build(
            guid: guid,
            sessionToken: sessionToken,
            code: code
        )
        return networkAdapter
            .perform(
                request: request,
                responseType: WalletPayloadWrapper.self
            )
            .catch { error -> AnyPublisher<WalletPayloadWrapper, ClientError> in
                switch error {
                case .payloadError(.badData(rawPayload: let payload)):
                    guard let clientError = ClientError(plainServerError: payload) else {
                        return .failure(.networkError(error))
                    }
                    switch clientError {
                    case .wrongCode(attemptsLeft: let attemptsLeft):
                        return .failure(.wrongCode(attemptsLeft: attemptsLeft))
                    case .accountLocked:
                        return .failure(.accountLocked)
                    case .networkError(let error):
                        return .failure(.networkError(error))
                    }
                case .rawServerError(let response):
                    guard let payloadData = response.payload,
                          let payload = String(data: payloadData, encoding: .utf8),
                          let clientError = ClientError(plainServerError: payload)
                    else {
                        return .failure(.networkError(error))
                    }
                    switch clientError {
                    case .wrongCode(attemptsLeft: let attemptsLeft):
                        return .failure(.wrongCode(attemptsLeft: attemptsLeft))
                    case .accountLocked:
                        return .failure(.accountLocked)
                    case .networkError(let error):
                        return .failure(.networkError(error))
                    }
                default:
                    return .failure(.networkError(error))
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - TwoFAWalletClient

extension TwoFAWalletClient {

    private struct TwoFARequestBuilder {

        private let pathComponents = ["wallet"]

        private enum Parameters {
            static let method = "method"
            static let guid = "guid"
            static let payload = "payload"
            static let length = "length"
            static let format = "format"
            static let apiCode = "apiCode"
        }

        private enum HeaderKey: String {
            case authorization = "Authorization"
        }

        // MARK: - Builder

        private let requestBuilder: RequestBuilder

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }

        // MARK: - API

        func build(guid: String, sessionToken: String, code: String) -> NetworkRequest {
            let headers = [HeaderKey.authorization.rawValue: "Bearer \(sessionToken)"]
            let parameters = [
                URLQueryItem(
                    name: Parameters.method,
                    value: "get-wallet"
                ),
                URLQueryItem(
                    name: Parameters.guid,
                    value: guid
                ),
                URLQueryItem(
                    name: Parameters.payload,
                    value: code
                ),
                URLQueryItem(
                    name: Parameters.length,
                    value: String(code.count)
                ),
                URLQueryItem(
                    name: Parameters.format,
                    value: "plain"
                ),
                URLQueryItem(
                    name: Parameters.apiCode,
                    value: "api_code"
                )
            ]
            let data = RequestBuilder.body(from: parameters)
            return requestBuilder.post(
                path: pathComponents,
                body: data,
                headers: headers,
                contentType: .formUrlEncoded
            )!
        }
    }
}
