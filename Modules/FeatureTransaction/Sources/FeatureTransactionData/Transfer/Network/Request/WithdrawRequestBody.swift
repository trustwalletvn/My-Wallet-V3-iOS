// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct WithdrawRequestBody: Encodable {
    let beneficiary: String
    let currency: String
    let amount: String
}
