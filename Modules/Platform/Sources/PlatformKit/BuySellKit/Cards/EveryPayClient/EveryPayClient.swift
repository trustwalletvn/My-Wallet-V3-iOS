// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import ToolKit

public final class EveryPayClient: EveryPayClientAPI {

    // MARK: - Types

    private enum Path {
        static let cardDetails = ["api", "v3", "mobile_payments", "card_details"]
    }

    private enum Parameter {
        static let apiUserName = "api_username"
        static let accessToken = "mobile_access_token"
        static let tokenConsented = "token_consented"
        static let cardDetails = "cc_details"
        static let nonce = "nonce"
        static let timestamp = "timestamp"

        static let cardNumber = "cc_number"
        static let month = "month"
        static let year = "year"
        static let cardholderName = "holder_name"
        static let cvc = "cvc"
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.everypay),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.everypay)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func send(
        cardDetails: CardPartnerPayload.EveryPay.SendCardDetailsRequest.CardDetails,
        apiUserName: String,
        token: String
    ) -> AnyPublisher<CardPartnerPayload.EveryPay.CardDetailsResponse, NetworkError> {
        let path = Path.cardDetails
        let headers = [HttpHeaderField.authorization: "Bearer \(token)"]
        let payload = CardPartnerPayload.EveryPay.SendCardDetailsRequest(
            apiUserName: apiUserName,
            nonce: UUID().uuidString,
            timestamp: DateFormatter.iso8601Format.string(from: Date()),
            cardDetails: cardDetails
        )

        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            headers: headers
        )!
        return networkAdapter.perform(request: request)
    }
}
