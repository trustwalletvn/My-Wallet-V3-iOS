// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct OrdersActivityResponse: Decodable {
    struct Item: Decodable {
        struct ExtraAttributes: Decodable {
            struct Beneficiary: Decodable {
                let accountRef: String?
            }

            let beneficiary: Beneficiary?
        }

        struct Amount: Decodable {
            let symbol: String
        }

        let id: String
        let amount: Amount
        let amountMinor: String
        let feeMinor: String?
        let insertedAt: String
        let type: String
        let state: String
        let extraAttributes: ExtraAttributes?
        let txHash: String?
    }

    let items: [Item]
}
