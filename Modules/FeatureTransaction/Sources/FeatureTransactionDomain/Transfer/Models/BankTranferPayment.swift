// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct BankTranferPayment {
    let paymentId: String
    let bankAccountType: String?

    public init(paymentId: String, bankAccountType: String?) {
        self.paymentId = paymentId
        self.bankAccountType = bankAccountType
    }
}
