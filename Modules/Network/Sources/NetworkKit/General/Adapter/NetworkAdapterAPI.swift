// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import RxCombine
import RxSwift
import ToolKit

/// Provides a bridge to so clients can continue consuming the `RxSwift` APIs temporarily
public protocol NetworkAdapterRxAPI {

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform(request: NetworkRequest) -> Completable

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Completable

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType>

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType>

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType>

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType>

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType?>

    @available(*, deprecated, message: "Don't use this. Clients should use the new publisher contract.")
    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType?>
}

/// The `Combine` network adapter API, all new uses of networking should consume this API
public protocol NetworkAdapterAPI: NetworkAdapterRxAPI {

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    /// - Returns: `Void` in case of success or `NetworkError` for failure
    func perform(request: NetworkRequest) -> AnyPublisher<Void, NetworkError>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    /// - Returns: `Void` on success or decodes the error
    ///              into a `FromNetworkErrorConvertible` conforming type.
    func perform<ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<Void, ErrorResponseType>

    /// Performs a request and maps the response or error response
    /// - Parameter request: the request to perform
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and maps the response or error response
    /// - Parameter request: the request to perform
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            `NetworkError` for the error case.
    func perform<ResponseType: Decodable>(
        request: NetworkRequest
    ) -> AnyPublisher<ResponseType, NetworkError>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and maps the response and returns any errors
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            `NetworkError` for the error case.
    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkError>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - errorResponseType: the type of the error response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and maps the response or error response
    /// - Parameters:
    /// - Parameter request: the request to perform
    ///   - responseType: the type of the response to map to
    ///   - errorResponseType: the type of the error response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    ///   - responseType: the type of the response to map to
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    /// - Returns: attempts to decode the success into `ResponseType` or
    ///            into a `FromNetworkErrorConvertible` conforming type for the error case.
    func performOptional(
        request: NetworkRequest
    ) -> AnyPublisher<Void, NetworkError>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    ///   - responseType: the type of the response to map to
    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType?, NetworkError>

    /// Performs a request and if there is content maps the response and always maps the error type
    /// - Parameters:
    ///   - request: the request to perform
    ///   - responseType: the type of the response to map to
    ///   - errorResponseType: the type of the error response to map to
    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType>
}

extension NetworkAdapterAPI {

    // MARK: - NetworkAdapterRxAPI

    func perform(request: NetworkRequest) -> Completable {
        perform(
            request: request,
            responseType: EmptyNetworkResponse.self
        )
        .asObservable()
        .ignoreElements()
        .probabilisticallyCrashOnRxError()
    }

    func perform<ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Completable {
        perform(
            request: request,
            responseType: EmptyNetworkResponse.self,
            errorResponseType: errorResponseType
        )
        .asObservable()
        .ignoreElements()
        .probabilisticallyCrashOnRxError()
    }

    func perform<ResponseType: Decodable>(request: NetworkRequest) -> Single<ResponseType> {
        perform(request: request, responseType: ResponseType.self)
            .probabilisticallyCrashOnRxError()
    }

    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType> {

        func performPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType, NetworkError> {
            perform(request: request)
        }

        return performPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
            .probabilisticallyCrashOnRxError()
    }

    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType> {
        perform(
            request: request,
            responseType: ResponseType.self,
            errorResponseType: errorResponseType
        )
        .probabilisticallyCrashOnRxError()
    }

    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType> {

        func performPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType, ErrorResponseType> {
            perform(request: request)
        }

        return performPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
            .probabilisticallyCrashOnRxError()
    }

    func performOptional<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> Single<ResponseType?> {

        func performOptionalPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType?, NetworkError> {
            performOptional(request: request, responseType: ResponseType.self)
        }

        return performOptionalPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
            .probabilisticallyCrashOnRxError()
    }

    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> Single<ResponseType?> {

        func performOptionalPublisher(
            request: NetworkRequest
        ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
            performOptional(request: request, responseType: ResponseType.self)
        }

        return performOptionalPublisher(request: request)
            .asObservable()
            .take(1)
            .asSingle()
            .probabilisticallyCrashOnRxError()
    }
}

extension NetworkAdapterAPI {

    func perform(request: NetworkRequest) -> AnyPublisher<Void, NetworkError> {
        perform(request: request)
            .map { (_: EmptyNetworkResponse) -> Void in
                ()
            }
            .eraseToAnyPublisher()
    }

    func perform<ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest
    ) -> AnyPublisher<Void, ErrorResponseType> {
        perform(request: request)
            .map { (_: EmptyNetworkResponse) -> Void in
                ()
            }
            .eraseToAnyPublisher()
    }

    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }

    func perform<ResponseType: Decodable>(
        request: NetworkRequest,
        responseType: ResponseType.Type
    ) -> AnyPublisher<ResponseType, NetworkError> {
        perform(request: request)
    }

    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }

    func perform<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType, ErrorResponseType> {
        perform(request: request)
    }

    func performOptional<ResponseType: Decodable, ErrorResponseType: FromNetworkErrorConvertible>(
        request: NetworkRequest,
        responseType: ResponseType.Type,
        errorResponseType: ErrorResponseType.Type
    ) -> AnyPublisher<ResponseType?, ErrorResponseType> {
        performOptional(request: request, responseType: responseType)
    }

    func performOptional(
        request: NetworkRequest
    ) -> AnyPublisher<Void, NetworkError> {
        perform(request: request, responseType: EmptyNetworkResponse.self)
            .mapToVoid()
    }
}

extension PrimitiveSequence {

    fileprivate func probabilisticallyCrashOnRxError() -> PrimitiveSequence {
        catchError { error in
            func crashOnError(_ error: Error) {
                switch error as? RxError {
                case .noElements:
                    fatalError("No elements received")
                case .moreThanOneElement:
                    fatalError("More than one element received")
                default:
                    break
                }
            }
            #if INTERNAL_BUILD
            crashOnError(error)
            #else
            ProbabilisticRunner.run(for: .pointZeroOnePercent) {
                crashOnError(error)
            }
            #endif
            throw error
        }
    }
}
