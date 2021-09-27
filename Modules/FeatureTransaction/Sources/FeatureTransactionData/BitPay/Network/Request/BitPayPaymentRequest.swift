// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BitPayPaymentRequest: Encodable {

    struct Transaction: Encodable {
        let tx: String
        let weightedSize: Int
    }

    let chain: String
    let transactions: [Transaction]

    init(chain: String, transactions: [Transaction]) {
        self.chain = chain
        self.transactions = transactions
    }
}
