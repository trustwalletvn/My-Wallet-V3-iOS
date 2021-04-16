//
//  NetworkResponseHandler.swift
//  NetworkKit
//
//  Created by Jack Pooley on 27/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import ToolKit

public protocol NetworkResponseHandlerAPI {
    
    /// Performs handling on the `data` and `response` returned by the network request
    /// - Parameters:
    ///   - elements: the `data` and `response` to handle
    ///   - request: the request corresponding to this response
    func handle(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorErrorNew>
}

final class NetworkResponseHandler: NetworkResponseHandlerAPI {
    
    func handle(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorErrorNew> {
        handler(elements: elements, for: request).publisher
    }
    
    // MARK: - Private methods
    
    private func handler(
        elements: (data: Data, response: URLResponse),
        for request: NetworkRequest
    ) -> Result<ServerResponseNew, NetworkCommunicatorErrorNew> {
        Result<(data: Data, response: URLResponse), NetworkCommunicatorErrorNew>.success(elements)
            .flatMap { elements -> Result<ServerResponseNew, NetworkCommunicatorErrorNew> in
                guard let response = elements.response as? HTTPURLResponse else {
                    return .failure(.serverError(.badResponse))
                }
                let payload = elements.data
                switch response.statusCode {
                case 204:
                    return .success(ServerResponseNew(payload: nil, response: response))
                case 200...299:
                    return .success(ServerResponseNew(payload: payload, response: response))
                default:
                    let requestPath = request.URLRequest.url?.path ?? ""
                    Logger.shared.debug("\(requestPath) failed with status code: \(response.statusCode)")
                    return .failure(
                        .rawServerError(
                            ServerErrorResponseNew(response: response, payload: payload)
                        )
                    )
                }
            }
    }
}