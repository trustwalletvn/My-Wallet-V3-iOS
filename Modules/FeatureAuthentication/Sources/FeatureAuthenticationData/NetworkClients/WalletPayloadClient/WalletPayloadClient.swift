// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit
import WalletPayloadKit

// TODO: fetch using a `sharedKey`
public final class WalletPayloadClient: WalletPayloadClientAPI {

    // MARK: - Types

    /// Errors thrown from the client layer
    public struct ClientResponse {

        // MARK: - Types

        let guid: String
        let authType: Int
        let language: String
        let shouldSyncPubkeys: Bool
        let time: Date

        /// Payload should be nullified if 2FA s required.
        /// Then `authType` should have a none 0 value.
        /// `AuthenticatorType` is an enum representation of the possible values.
        let payload: WalletPayloadWrapper?

        init(response: Response) throws {
            guard let guid = response.guid else {
                throw ClientError.missingGuid
            }
            payload = try? WalletPayloadWrapper(string: response.payload)
            self.guid = guid
            authType = response.authType
            language = response.language
            shouldSyncPubkeys = response.shouldSyncPubkeys
            time = Date(timeIntervalSince1970: response.serverTime / 1000)
        }
    }

    /// Errors thrown from the client layer
    public enum ClientError: Error {

        private enum RawErrorSubstring {
            static let accountLocked = "locked"
        }

        /// Payload is missing
        case missingPayload

        /// Server returned response `nil` GUID
        case missingGuid

        /// Email authorization required
        case emailAuthorizationRequired

        /// Account is locked
        case accountLocked

        /// Server returned an unfamiliar user readable error
        case message(String)

        /// Another error
        case unknown

        init(response: ErrorResponse) {
            if response.isEmailAuthorizationRequired {
                self = .emailAuthorizationRequired
            } else if let message = response.errorMessage {
                // This is the only way to extract that error type
                if message.contains(RawErrorSubstring.accountLocked) {
                    self = .accountLocked
                } else {
                    self = .message(message)
                }
            } else {
                self = .unknown
            }
        }
    }

    /// Error returned from the server
    struct ErrorResponse: FromNetworkErrorConvertible {

        static func from(_ communicatorError: NetworkError) -> WalletPayloadClient.ErrorResponse {
            ErrorResponse(
                isEmailAuthorizationRequired: false,
                errorMessage: String(describing: communicatorError)
            )
        }

        enum CodingKeys: String, CodingKey {
            case isEmailAuthorizationRequired = "authorization_required"
            case errorMessage = "initial_error"
        }

        let isEmailAuthorizationRequired: Bool
        let errorMessage: String?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            isEmailAuthorizationRequired = try container.decodeIfPresent(
                Bool.self,
                forKey: .isEmailAuthorizationRequired
            ) ?? false
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
        }

        private init(
            isEmailAuthorizationRequired: Bool,
            errorMessage: String?
        ) {
            self.isEmailAuthorizationRequired = isEmailAuthorizationRequired
            self.errorMessage = errorMessage
        }
    }

    /// Response returned from the server
    struct Response {
        let guid: String?
        let authType: Int
        let language: String
        let serverTime: TimeInterval
        let payload: String?
        let shouldSyncPubkeys: Bool
    }

    /// The identifier through which the wallet payload is fetched
    public enum Identifier {

        /// Session token (e.g pairing)
        case sessionToken(String)

        /// Shared key (e.g PIN auth)
        case sharedKey(String)
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: WalletPayloadRequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = WalletPayloadRequestBuilder(requestBuilder: requestBuilder)
    }

    // MARK: - API

    public func payload(
        guid: String,
        identifier: Identifier
    ) -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadClient.ClientError> {
        let request = requestBuilder.build(identifier: identifier, guid: guid)
        return networkAdapter
            .perform(
                request: request,
                responseType: Response.self,
                errorResponseType: ErrorResponse.self
            )
            .mapError(ClientError.init)
            .flatMap { response -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadClient.ClientError> in
                WalletPayloadClient.responseResult(response: response)
                    .publisher
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Methods

    private static func responseResult(response: Response) -> Result<ClientResponse, ClientError> {
        do {
            let clientResponse = try ClientResponse(response: response)
            return .success(clientResponse)
        } catch {
            guard let clientError = error as? ClientError else {
                fatalError("Error must be of type ClientError")
            }
            return .failure(clientError)
        }
    }
}

extension WalletPayloadClient {

    private struct WalletPayloadRequestBuilder {

        private let pathComponents = ["wallet"]

        private enum HeaderKey: String {
            case cookie
        }

        private enum Query: String {
            case sharedKey
            case format
            case time = "ct"
        }

        // MARK: - Builder

        private let requestBuilder: RequestBuilder

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }

        // MARK: - API

        func build(identifier: Identifier, guid: String) -> NetworkRequest {
            let pathComponents = self.pathComponents + [guid]
            var headers: HTTPHeaders = [:]
            var parameters: [URLQueryItem] = []

            switch identifier {
            case .sessionToken(let token):
                headers = [HeaderKey.cookie.rawValue: "SID=\(token)"]
            case .sharedKey(let sharedKey):
                parameters += [
                    URLQueryItem(
                        name: Query.sharedKey.rawValue,
                        value: sharedKey
                    )
                ]
            }
            parameters += [
                URLQueryItem(
                    name: Query.format.rawValue,
                    value: "json"
                ),
                URLQueryItem(
                    name: Query.time.rawValue,
                    value: String(Int(Date().timeIntervalSince1970 * 1000.0))
                )
            ]

            return requestBuilder.get(
                path: pathComponents,
                parameters: parameters,
                headers: headers
            )!
        }
    }
}

extension WalletPayloadClient.Response: Decodable {

    enum CodingKeys: String, CodingKey {
        case guid
        case payload
        case authType = "real_auth_type"
        case shouldSyncPubkeys = "sync_pubkeys"
        case language
        case serverTime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guid = try container.decode(String.self, forKey: .guid)
        authType = try container.decode(Int.self, forKey: .authType)
        language = try container.decode(String.self, forKey: .language)
        shouldSyncPubkeys = try container.decodeIfPresent(Bool.self, forKey: .shouldSyncPubkeys) ?? false
        payload = try container.decodeIfPresent(String.self, forKey: .payload)
        serverTime = try container.decode(TimeInterval.self, forKey: .serverTime)
    }
}
