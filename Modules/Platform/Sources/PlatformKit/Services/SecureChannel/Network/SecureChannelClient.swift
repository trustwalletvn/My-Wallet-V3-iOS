// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift

/// Secure Channel network service
final class SecureChannelClient {

    // MARK: - Types

    enum SendSecureChannelError: Error {
        case couldNotBuildRequestBody
        case networkFailure
        case emptyCredentials
        case unknownReceiver
    }

    private struct SendMessageResponse: Decodable {
        let success: Bool
    }

    private struct GetIpResponse: Decodable {
        let ip: String
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
}

// MARK: - SecureChannelClientAPI

extension SecureChannelClient: SecureChannelClientAPI {

    private func sendMessageRequest(msg: SecureChannel.PairingResponse) -> NetworkRequest? {
        let encoded = try? JSONEncoder().encode(msg)
        let serialised = String(data: encoded!, encoding: .utf8)!
        return requestBuilder.post(
            path: ["wallet"],
            parameters: [
                URLQueryItem(name: "method", value: "send-secure-channel"),
                URLQueryItem(name: "payload", value: serialised),
                URLQueryItem(name: "length", value: "\(serialised.count)"),
                URLQueryItem(name: "api_code", value: BlockchainAPI.Parameters.apiCode)
            ]
        )
    }

    func sendMessage(msg: SecureChannel.PairingResponse) -> Completable {
        guard let request = sendMessageRequest(msg: msg) else {
            return .error(SendSecureChannelError.networkFailure)
        }
        return networkAdapter.perform(request: request)
            .map { (response: SendMessageResponse) -> Void in
                guard response.success else {
                    throw SendSecureChannelError.networkFailure
                }
            }
            .asCompletable()
    }

    private func getIPRequest() -> NetworkRequest? {
        requestBuilder.get(
            path: ["wallet", "get-ip"]
        )
    }

    func getIp() -> Single<String> {
        guard let request = getIPRequest() else {
            return .error(SendSecureChannelError.networkFailure)
        }
        return networkAdapter.perform(request: request)
            .map { (response: GetIpResponse) -> String in
                response.ip
            }
    }
}
