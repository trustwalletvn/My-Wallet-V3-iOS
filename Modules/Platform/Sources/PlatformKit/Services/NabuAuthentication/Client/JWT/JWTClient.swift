// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

protocol JWTClientAPI: AnyObject {

    func requestJWT(guid: String, sharedKey: String) -> AnyPublisher<String, JWTClient.ClientError>
}

final class JWTClient: JWTClientAPI {

    // MARK: - Types

    enum ClientError: Error {
        case jwt(String)
    }

    private struct JWTResponse: Decodable {
        let success: Bool
        let token: String?
        let error: String?
    }

    private enum Path {
        static let token = ["wallet", "signed-retail-token"]
    }

    private enum Parameter {
        static let guid = "guid"
        static let sharedKey = "sharedKey"
        static let apiCode = "api_code"
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func requestJWT(guid: String, sharedKey: String) -> AnyPublisher<String, JWTClient.ClientError> {
        let queryParameters = [
            URLQueryItem(
                name: Parameter.guid,
                value: guid
            ),
            URLQueryItem(
                name: Parameter.sharedKey,
                value: sharedKey
            ),
            URLQueryItem(
                name: Parameter.apiCode,
                value: BlockchainAPI.Parameters.apiCode
            )
        ]
        let request = requestBuilder.get(
            path: Path.token,
            parameters: queryParameters
        )!
        return networkAdapter.perform(request: request)
            .mapError { (networkError: NetworkError) -> JWTClient.ClientError in
                .jwt(String(describing: networkError))
            }
            .flatMap { (response: JWTResponse) -> AnyPublisher<String, JWTClient.ClientError> in
                guard response.success else {
                    return .failure(ClientError.jwt(response.error ?? ""))
                }
                guard let token = response.token else {
                    return .failure(ClientError.jwt(response.error ?? ""))
                }
                return .just(token)
            }
            .eraseToAnyPublisher()
    }
}
