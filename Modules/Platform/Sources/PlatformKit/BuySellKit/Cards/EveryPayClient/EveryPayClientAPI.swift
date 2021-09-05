// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit
import RxSwift

public protocol EveryPayClientAPI: AnyObject {
    func send(
        cardDetails: CardPartnerPayload.EveryPay.SendCardDetailsRequest.CardDetails,
        apiUserName: String,
        token: String
    ) -> Single<CardPartnerPayload.EveryPay.CardDetailsResponse>
}
