// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import NetworkKit
import TestKit
import ToolKit
import UIKit

final class NetworkAdapterMock: NetworkAdapterAPI {

    var response: (filename: String, bundle: Bundle)?

    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkError> {
        decode()
    }

    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        decode()
    }

    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        decode()
    }

    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkError> {
        decode()
    }

    private func decode<ResponseType: Decodable>(
    ) -> AnyPublisher<ResponseType, NetworkError> {
        guard
            let response = response,
            let fixture: ResponseType = Fixtures.load(name: response.filename, in: response.bundle)
        else {
            return .failure(NetworkError.payloadError(.emptyData))
        }
        return .just(fixture)
    }

    private func decode<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        guard
            let response = response,
            let fixture: ResponseType = Fixtures.load(name: response.filename, in: response.bundle)
        else {
            return .failure(ErrorResponseType.from(NetworkError.payloadError(.emptyData)))
        }
        return .just(fixture)
    }
}
