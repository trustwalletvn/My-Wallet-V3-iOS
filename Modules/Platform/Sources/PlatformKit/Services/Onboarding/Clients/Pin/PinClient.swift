// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift

/// Responsible for networking
public final class PinClient: PinClientAPI {

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let apiURL = URL(string: BlockchainAPI.shared.pinStore)!

    // MARK: - Setup

    public init(networkAdapter: NetworkAdapterAPI = resolve()) {
        self.networkAdapter = networkAdapter
    }

    /// Creates a new pin in the remote pin store
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: a Single returning the response
    public func create(pinPayload: PinPayload) -> Single<PinStoreResponse> {
        let requestPayload = StoreRequestData(payload: pinPayload, requestType: .create)
        let data = ParameterEncoder(requestPayload.dictionary).encoded
        let request = NetworkRequest(
            endpoint: apiURL,
            method: .post,
            body: data,
            contentType: .formUrlEncoded
        )
        return networkAdapter
            .perform(
                request: request,
                responseType: PinStoreResponse.self,
                errorResponseType: PinStoreResponse.self
            )
    }

    /// Validates if the provided pin payload (i.e. pin code and pin key combination) is correct.
    ///
    /// - Parameter pinPayload: the PinPayload
    /// - Returns: an Single returning the response
    public func validate(pinPayload: PinPayload) -> Single<PinStoreResponse> {
        let requestPayload = StoreRequestData(payload: pinPayload, requestType: .validate)
        let data = ParameterEncoder(requestPayload.dictionary).encoded
        let request = NetworkRequest(
            endpoint: apiURL,
            method: .post,
            body: data,
            contentType: .formUrlEncoded
        )
        return networkAdapter
            .perform(
                request: request,
                responseType: PinStoreResponse.self,
                errorResponseType: PinStoreResponse.self
            )
    }
}

// MARK: - StoreRequestData

extension PinClient {

    struct StoreRequestData: Encodable {

        // MARK: - Types

        /// The type of the request. this is a weird legacy -
        /// we send the type of the request as a parameter (!?)
        /// instead of just using `HTTPMethod`
        enum RequestType: String, Encodable {
            enum CodingKeys: CodingKey {
                case create
                case validate
            }

            case create = "put"
            case validate = "get"
        }

        enum CodingKeys: String, CodingKey {
            case format
            case pin
            case key
            case value
            case apiCode = "api_code"
            case requestType = "method"
        }

        // MARK: - Properties

        let format = "json"
        let apiCode = BlockchainAPI.Parameters.apiCode
        let pin: String
        let key: String
        let value: String?
        let requestType: RequestType

        // MARK: - Setup

        init(payload: PinPayload, requestType: RequestType) {
            pin = payload.pinCode
            key = payload.pinKey
            value = payload.pinValue
            self.requestType = requestType
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(format, forKey: .format)
            try container.encode(apiCode, forKey: .apiCode)
            try container.encode(pin, forKey: .pin)
            try container.encode(key, forKey: .key)
            try container.encode(value, forKey: .value)
            try container.encode(requestType, forKey: .requestType)
        }
    }
}
