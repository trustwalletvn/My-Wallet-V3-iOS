// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol EveryPayClientAPI: AnyObject {
    func send(
        cardDetails: CardPartnerPayload.EveryPay.SendCardDetailsRequest.CardDetails,
        apiUserName: String,
        token: String
    ) -> AnyPublisher<CardPartnerPayload.EveryPay.CardDetailsResponse, NetworkError>
}
