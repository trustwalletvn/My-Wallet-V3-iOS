// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct WithdrawalPayload: Encodable {
    let beneficiary: String
    let amount: String
    let currency: String

    init(data: WithdrawalCheckoutData) {
        beneficiary = data.beneficiary.identifier
        amount = data.amount.minorString
        currency = data.currency.code
    }
}
