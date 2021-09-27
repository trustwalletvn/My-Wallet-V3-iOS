// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

typealias CardClientAPI = CardListClientAPI &
    CardChargeClientAPI &
    CardDeletionClientAPI &
    CardActivationClientAPI &
    CardDetailClientAPI &
    CardAdditionClientAPI

final class CardClient: CardClientAPI {

    // MARK: - Types

    private enum Parameter {
        static let currency = "currency"
    }

    private enum Path {
        static let card = ["payments", "cards"]

        static func activateCard(with id: String) -> [String] { Path.card + [id, "activate"] }
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - CardListClientAPI

    /// Streams a list of available cards
    /// - Returns: A Single with `CardPayload` array
    var cardList: AnyPublisher<[CardPayload], NabuNetworkError> {
        let path = Path.card
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - CardDetailClientAPI

    func getCard(by id: String) -> AnyPublisher<CardPayload, NabuNetworkError> {
        let path = Path.card + [id]
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - CardDeletionClientAPI

    func deleteCard(by id: String) -> AnyPublisher<Void, NabuNetworkError> {
        let path = Path.card + [id]
        let request = requestBuilder.delete(
            path: path,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - CardChargeClientAPI

    func chargeCard(by id: String) -> AnyPublisher<Void, NabuNetworkError> {
        let path = Path.card + [id, "charge"]
        let request = requestBuilder.post(
            path: path,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - CardAdditionClientAPI

    func add(
        for currency: String,
        email: String,
        billingAddress: CardPayload.BillingAddress
    ) -> AnyPublisher<CardPayload, NabuNetworkError> {
        struct RequestPayload: Encodable {
            let currency: String
            let email: String
            let address: CardPayload.BillingAddress
        }

        let payload = RequestPayload(
            currency: currency,
            email: email,
            address: billingAddress
        )

        let path = Path.card
        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - CardActivationClientAPI

    /// EveryPay Only (Other provider would need different methods)
    /// Attempt to register the card method with the partner.
    /// Successful response should have card object and status should move to ACTIVE.
    /// - Parameters:
    ///   - id: ID of the card
    ///   - url: Everypay only - URL to return to after card verified
    ///   - token: Session token
    /// - Returns: The card details
    func activateCard(
        by id: String,
        url: String
    ) -> AnyPublisher<ActivateCardResponse.Partner, NabuNetworkError> {
        struct Attributes: Encodable {
            struct EveryPay: Encodable {
                let customerUrl: String
            }

            private let everypay: EveryPay?

            init(everypay: EveryPay) {
                self.everypay = everypay
            }
        }

        let path = Path.activateCard(with: id)
        let payload = Attributes(everypay: .init(customerUrl: url))

        let request = requestBuilder.post(
            path: path,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
            .map { (response: ActivateCardResponse) in
                response.partner
            }
            .eraseToAnyPublisher()
    }
}
