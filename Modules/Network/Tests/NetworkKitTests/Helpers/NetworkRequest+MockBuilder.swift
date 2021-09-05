// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import NetworkKit
import ToolKit

class InternalFeatureFlagServiceMock: InternalFeatureFlagServiceAPI {
    func isEnabled(_ feature: InternalFeature) -> Bool {
        true
    }

    func enable(_ feature: InternalFeature) {}
    func enable(_ features: [InternalFeature]) {}
    func disable(_ feature: InternalFeature) {}
}

extension NetworkRequest {

    final class MockBuilder {
        private var endpoint = URL(string: "https://blockchain.com")!
        private var method: NetworkMethod = .get
        private var body: Data?
        private var headers: HTTPHeaders = [:]
        private var authenticated: Bool = false
        private var contentType: ContentType = .json
        private var decoder: NetworkResponseDecoderAPI =
            NetworkResponseDecoder(
                interalFeatureFlagService: InternalFeatureFlagServiceMock()
            )
        private var responseHandler: NetworkResponseHandlerAPI = NetworkResponseHandler()
        private var recordErrors: Bool = true

        func with(endpoint: URL) -> Self {
            self.endpoint = endpoint
            return self
        }

        func with(method: NetworkMethod) -> Self {
            self.method = method
            return self
        }

        func with(body: Data) -> Self {
            self.body = body
            return self
        }

        func with(headers: HTTPHeaders) -> Self {
            self.headers = headers
            return self
        }

        func with(authenticated: Bool) -> Self {
            self.authenticated = authenticated
            return self
        }

        func with(contentType: ContentType) -> Self {
            self.contentType = contentType
            return self
        }

        func with(decoder: NetworkResponseDecoderAPI) -> Self {
            self.decoder = decoder
            return self
        }

        func with(responseHandler: NetworkResponseHandlerAPI) -> Self {
            self.responseHandler = responseHandler
            return self
        }

        func with(recordErrors: Bool) -> Self {
            self.recordErrors = recordErrors
            return self
        }

        func build() -> NetworkRequest {
            NetworkRequest(
                endpoint: endpoint,
                method: method,
                body: body,
                headers: headers,
                authenticated: authenticated,
                contentType: contentType,
                decoder: decoder,
                responseHandler: responseHandler,
                recordErrors: recordErrors
            )
        }
    }
}
