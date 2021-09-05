// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct WithdrawalAmountResponse: Decodable {
    let symbol: String
    let value: String
}

public struct WithdrawalCheckoutResponse: Decodable {
    let id: String
    let user: String
    let product: String
    let state: String
    let amount: WithdrawalAmountResponse
}
