// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

public protocol NabuSessionTokenClientAPI: AnyObject {

    func sessionToken(
        for guid: String,
        userToken: String,
        userIdentifier: String,
        deviceId: String,
        email: String
    ) -> AnyPublisher<NabuSessionTokenResponse, NetworkError>
}

final class NabuSessionTokenClient: NabuSessionTokenClientAPI {

    // MARK: - Types

    private enum Parameter: String {
        case userId
    }

    private enum Path {
        static let auth = ["auth"]
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func sessionToken(
        for guid: String,
        userToken: String,
        userIdentifier: String,
        deviceId: String,
        email: String
    ) -> AnyPublisher<NabuSessionTokenResponse, NetworkError> {
        let headers: [String: String] = [
            HttpHeaderField.appVersion: Bundle.applicationVersion ?? "",
            HttpHeaderField.clientType: HttpHeaderValue.clientTypeApp,
            HttpHeaderField.deviceId: deviceId,
            HttpHeaderField.authorization: userToken,
            HttpHeaderField.walletGuid: guid,
            HttpHeaderField.walletEmail: email
        ]
        let parameters = [
            URLQueryItem(
                name: Parameter.userId.rawValue,
                value: userIdentifier
            )
        ]
        let request = requestBuilder.post(
            path: Path.auth,
            parameters: parameters,
            headers: headers
        )!
        return networkAdapter.perform(request: request)
    }
}
