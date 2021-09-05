// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit

public protocol NetworkResponseHandlerAPI {

    /// Performs handling on the `data` and `response` returned by the network request
    /// - Parameters:
    ///   - elements: the `data` and `response` to handle
    ///   - request: the request corresponding to this response
    func handle(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError>
}

extension Data {
    fileprivate func unescapedJSONString() throws -> String {
        let object = try JSONSerialization.jsonObject(with: self, options: .allowFragments)
        let unescapedData = try JSONSerialization.data(withJSONObject: object, options: .withoutEscapingSlashes)
        guard let string = String(data: unescapedData, encoding: .utf8) else {
            throw NetworkError.payloadError(.badData(rawPayload: String(describing: object)))
        }
        return string
    }
}

final class NetworkResponseHandler: NetworkResponseHandlerAPI {

    func handle(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        handler(elements: elements, for: request).publisher
    }

    // MARK: - Private methods

    private func handler(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> Result<ServerResponse, NetworkError> {
        Result<(data: Data, response: URLResponse), NetworkError>.success(elements)
            .flatMap { elements -> Result<ServerResponse, NetworkError> in
                guard let response = elements.response as? HTTPURLResponse else {
                    return .failure(.serverError(.badResponse))
                }
                let payload = elements.data
                switch response.statusCode {
                case 204:
                    return .success(ServerResponse(payload: nil, response: response))
                case 200...299:
                    #if INTERNAL_BUILD
                    if request.shouldDebug, let json = try? payload.unescapedJSONString() {
                        Logger.shared.debug("[NetworkKit] Received response for \(request) => \(json)")
                    }
                    #endif
                    return .success(ServerResponse(payload: payload, response: response))
                default:
                    let requestPath = request.urlRequest.url?.path ?? ""
                    #if INTERNAL_BUILD
                    if let json = try? JSONSerialization.jsonObject(with: payload, options: .allowFragments) {
                        Logger.shared.error("\(json)")
                    }
                    #endif
                    Logger.shared.error("\(requestPath) failed with status code: \(response.statusCode)")
                    return .failure(
                        .rawServerError(
                            ServerErrorResponse(response: response, payload: payload)
                        )
                    )
                }
            }
    }
}
