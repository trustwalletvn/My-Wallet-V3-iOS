// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import RxCombine
import RxSwift
import ToolKit

final class NetworkAdapter: NetworkAdapterAPI {

    private let communicator: NetworkCommunicatorAPI
    private let queue: DispatchQueue

    init(
        communicator: NetworkCommunicatorAPI = resolve(),
        queue: DispatchQueue = DispatchQueue.global(qos: .default)
    ) {
        self.communicator = communicator
        self.queue = queue
    }

    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkError> {
        communicator.dataTaskPublisher(for: request)
            .decodeOptional(responseType: responseType, for: request, using: request.decoder)
            .subscribe(on: queue)
            .eraseToAnyPublisher()
    }

    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        communicator.dataTaskPublisher(for: request)
            .decodeOptional(responseType: responseType, for: request, using: request.decoder)
            .subscribe(on: queue)
            .eraseToAnyPublisher()
    }

    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        communicator.dataTaskPublisher(for: request)
            .decode(for: request, using: request.decoder)
            .subscribe(on: queue)
            .eraseToAnyPublisher()
    }

    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkError> {
        communicator.dataTaskPublisher(for: request)
            .decode(for: request, using: request.decoder)
            .subscribe(on: queue)
            .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
    Failure == NetworkError
{

    fileprivate func decodeOptional<ResponseType: Decodable>(
        responseType: ResponseType.Type,
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, NetworkError> {
        decodeOptionalSuccess(for: request, responseType: responseType, using: decoder)
    }

    fileprivate func decodeOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        responseType: ResponseType.Type,
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        decodeError(for: request, using: decoder)
            .decodeOptionalSuccess(for: request, responseType: responseType, using: decoder)
    }

    fileprivate func decode<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        decodeError(for: request, using: decoder)
            .decodeSuccess(for: request, using: decoder)
    }

    fileprivate func decode<ResponseType: Decodable>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, NetworkError> {
        decodeSuccess(for: request, using: decoder)
    }
}

extension AnyPublisher where Output == ServerResponse,
    Failure == NetworkError
{

    fileprivate func decodeError<ErrorResponseType: FromNetworkErrorConvertible>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ServerResponse, ErrorResponseType> {
        mapError { communicatorError -> ErrorResponseType in
            switch communicatorError {
            case .rawServerError(let rawServerError):
                return decoder.decode(
                    error: rawServerError, for: request
                )
            default:
                return ErrorResponseType.from(communicatorError)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
    Failure: FromNetworkErrorConvertible
{

    fileprivate func decodeSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, Failure> {
        flatMap { response -> AnyPublisher<ResponseType, Failure> in
            decoder.decode(response: response, for: request).publisher
        }
        .eraseToAnyPublisher()
    }

    fileprivate func decodeOptionalSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, Failure> {
        flatMap { response -> AnyPublisher<ResponseType?, Failure> in
            decoder
                .decodeOptional(
                    response: response,
                    responseType: responseType,
                    for: request
                )
                .publisher
        }
        .eraseToAnyPublisher()
    }
}

extension AnyPublisher where Output == ServerResponse,
    Failure == NetworkError
{

    fileprivate func decodeSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType, NetworkError> {
        flatMap { response -> AnyPublisher<ResponseType, NetworkError> in
            decoder.decode(response: response, for: request).publisher
        }
        .eraseToAnyPublisher()
    }

    fileprivate func decodeOptionalSuccess<ResponseType: Decodable>(
        for request: NetworkRequest,
        responseType: ResponseType.Type,
        using decoder: NetworkResponseDecoderAPI
    ) -> AnyPublisher<ResponseType?, NetworkError> {
        flatMap { response -> AnyPublisher<ResponseType?, NetworkError> in
            decoder
                .decodeOptional(
                    response: response,
                    responseType: responseType,
                    for: request
                )
                .publisher
        }
        .eraseToAnyPublisher()
    }
}
