// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct PushTxRequest: Encodable {
    let rawTx: String
    let api_code: String
}
