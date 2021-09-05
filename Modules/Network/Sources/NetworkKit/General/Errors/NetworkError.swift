// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

/// A networking error returned by the network layer, this can be mapped to user facing errors at a high level
public enum NetworkError: Error {
    case urlError(URLError)
    case serverError(HTTPRequestServerError)
    case rawServerError(ServerErrorResponse)
    case payloadError(HTTPRequestPayloadError)
    case authentication(Error)

    func analyticsEvent(
        for request: NetworkRequest,
        decodeErrorResponse: ((ServerErrorResponse) -> String?)? = nil
    ) -> AnalyticsEvent? {
        switch self {
        case .urlError(let urlError):
            return NetworkErrorEvent(request: request, error: urlError)
        case .rawServerError, .serverError, .payloadError, .authentication:
            return APIErrorEvent(
                request: request,
                error: self,
                decodeErrorResponse: decodeErrorResponse
            )
        }
    }
}

extension NetworkError: FromNetworkError {

    public static func from(_ networkError: NetworkError) -> NetworkError {
        networkError
    }
}

/// Errors returned when there is an unexpected response
public enum HTTPRequestServerError: Error {
    case badResponse
}

/// Errors to represent invalid or empty payload errors
public enum HTTPRequestPayloadError: Error {
    case emptyData
    case badData(rawPayload: String)
}

/// A simple implementation of `Equatable` for now. I might make sense to improve this, eventually.
extension NetworkError: Equatable {

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}
