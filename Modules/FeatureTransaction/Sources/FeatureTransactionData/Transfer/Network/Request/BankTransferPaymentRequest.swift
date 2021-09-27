// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct BankTransferPaymentRequest: Encodable {
    struct BankTransferPaymentAttributes: Encodable {
        let callback: String?
    }

    let amountMinor: String
    let currency: String
    let product: String = "SIMPLEBUY"
    let attributes: BankTransferPaymentAttributes?
}
