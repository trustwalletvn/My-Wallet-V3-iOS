// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct BitpayPaymentRequestResponse: Codable {

    struct Output: Codable {
        let amount: Int
        let address: String
    }

    struct Instructions: Codable {
        let outputs: [Output]
    }

    var outputs: [Output] {
        instructions
            .map(\.outputs)
            .flatMap { $0 }
    }

    let memo: String
    let expires: String
    let paymentUrl: String
    let paymentId: String

    private let instructions: [Instructions]
}
