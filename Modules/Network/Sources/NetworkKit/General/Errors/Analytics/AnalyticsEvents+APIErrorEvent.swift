// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

enum APIErrorEvent: AnalyticsEvent {
    case payloadError(ErrorDetails?)
    case serverError(ErrorDetails?)

    struct ErrorDetails {
        var params: [String: String] {
            var parameters: [String: String] = [
                "host": host,
                "path": path
            ]
            if let errorCode = errorCode {
                parameters["error_code"] = errorCode
            }
            if let body = body {
                parameters["body"] = body
            }
            if let requestId = requestId {
                parameters["request_id"] = requestId
            }
            return parameters
        }

        let host: String
        let path: String
        let errorCode: String?
        let body: String?
        let requestId: String?

        init?(request: NetworkRequest, errorResponse: ServerErrorResponse? = nil, body: String? = nil) {
            guard
                let url = request.urlRequest.url,
                let host = url.host
            else {
                return nil
            }
            var errorCode: String?
            if let statusCode = errorResponse?.response.statusCode {
                errorCode = "\(statusCode)"
            }
            var requestId: String?
            if let headers = errorResponse?.response.allHeaderFields, let requestIdHeader = headers["X-WR-RequestId"] as? String {
                requestId = requestIdHeader
            }
            self.host = host
            path = url.path
            self.errorCode = errorCode
            self.body = body
            self.requestId = requestId
        }
    }

    var name: String {
        "api_error"
    }

    var params: [String: String]? {
        switch self {
        case .payloadError(let details), .serverError(let details):
            return details?.params ?? [:]
        }
    }

    init?(
        request: NetworkRequest,
        error: NetworkError,
        decodeErrorResponse: ((ServerErrorResponse) -> String?)? = nil
    ) {
        switch error {
        case .rawServerError(let rawServerError):
            self = .serverError(ErrorDetails(
                request: request,
                errorResponse: rawServerError,
                body: decodeErrorResponse?(rawServerError)
            ))
        case .serverError, .payloadError, .authentication:
            self = .serverError(
                ErrorDetails(
                    request: request
                )
            )
        case .urlError:
            return nil
        }
    }
}
