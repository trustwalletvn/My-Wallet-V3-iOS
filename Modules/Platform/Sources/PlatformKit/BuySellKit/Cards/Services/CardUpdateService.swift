// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxSwift

/// A service API that aggregates card addition logic
public protocol CardUpdateServiceAPI: AnyObject {
    func add(card: CardData) -> Single<PartnerAuthorizationData>
}

public final class CardUpdateService: CardUpdateServiceAPI {

    // MARK: - Types

    public enum ServiceError: Error {
        case unknownPartner
    }

    private enum CardUpdateEvent: AnalyticsEvent {
        case sbAddCardFailure
        case sbCardActivationFailure
        case sbCardEverypayFailure(data: String)

        var name: String {
            switch self {
            case .sbAddCardFailure:
                return "sb_add_card_failure"
            case .sbCardActivationFailure:
                return "sb_card_activation_failure"
            case .sbCardEverypayFailure:
                return "sb_card_everypay_failure"
            }
        }

        var params: [String: String]? {
            switch self {
            case .sbCardEverypayFailure(data: let data):
                return ["data": data]
            default:
                return nil
            }
        }
    }

    // MARK: - Injected

    private let cardClient: CardClientAPI
    private let everyPayClient: EveryPayClientAPI
    private let dataRepository: DataRepositoryAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - Setup

    init(
        dataRepository: DataRepositoryAPI = resolve(),
        cardClient: CardClientAPI = resolve(),
        everyPayClient: EveryPayClientAPI = resolve(),
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.dataRepository = dataRepository
        self.cardClient = cardClient
        self.everyPayClient = everyPayClient
        self.analyticsRecorder = analyticsRecorder
        self.fiatCurrencyService = fiatCurrencyService
    }

    public func add(card: CardData) -> Single<PartnerAuthorizationData> {

        // Get the user email
        let email = dataRepository.userSingle
            .map(\.email.address)

        return Single.zip(
            fiatCurrencyService.fiatCurrency,
            email
        )
        .map { (currency: $0.0, email: $0.1) }
        // 1. Add the card details via BE
        .flatMap(weak: self) { (self, payload) -> Single<CardPayload> in
            self.cardClient
                .add(
                    for: payload.currency.code,
                    email: payload.email,
                    billingAddress: card.billingAddress.requestPayload
                )
                .do(onError: { _ in
                    self.analyticsRecorder.record(event: CardUpdateEvent.sbAddCardFailure)
                })
        }
        // 2. Make sure the card partner is supported
        .map { payload -> CardPayload in
            guard payload.partner.isKnown else {
                throw ServiceError.unknownPartner
            }
            return payload
        }
        // 3. Activate the card
        .flatMap(weak: self) { (self, payload) -> Single<(cardId: String, partner: ActivateCardResponse.Partner)> in
            self.cardClient.activateCard(
                by: payload.identifier,
                url: PartnerAuthorizationData.exitLink
            )
            .map {
                (cardId: payload.identifier, partner: $0)
            }
            .do(onError: { _ in
                self.analyticsRecorder.record(event: CardUpdateEvent.sbCardActivationFailure)
            })
        }
        // 4. Partner
        .flatMap(weak: self) { (self, payload) -> Single<PartnerAuthorizationData> in
            self
                .add(
                    card: card,
                    via: payload.partner
                )
                .map {
                    PartnerAuthorizationData(
                        state: $0,
                        paymentMethodId: payload.cardId
                    )
                }
        }
    }

    // MARK: - Partner Integration

    private func add(
        card: CardData,
        via partner: ActivateCardResponse.Partner
    ) -> Single<PartnerAuthorizationData.State> {
        switch partner {
        case .everypay(let data):
            return add(card: card, with: data)
        case .unknown:
            return .error(ServiceError.unknownPartner)
        }
    }

    /// Add via every pay
    private func add(
        card: CardData,
        with everyPayData: ActivateCardResponse.Partner.EveryPayData
    ) -> Single<PartnerAuthorizationData.State> {
        everyPayClient
            .send(
                cardDetails: card.everyPayCardDetails,
                apiUserName: everyPayData.apiUsername,
                token: everyPayData.mobileToken
            )
            .map { response -> PartnerAuthorizationData.State in
                switch response.status {
                case .waitingFor3DResponse:
                    let url = URL(string: everyPayData.paymentLink)!
                    return .required(.init(paymentLink: url))
                case .failed, .authorized, .settled, .waitingForBav:
                    return .none
                }
            }
            .do(onError: { [weak self] error in
                self?.analyticsRecorder.record(
                    event: CardUpdateEvent.sbCardEverypayFailure(data: String(describing: error))
                )
            })
    }
}
