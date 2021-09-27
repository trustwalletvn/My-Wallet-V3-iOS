// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension TransactionConfirmation {
    public enum Kind {
        case description
        case agreementInterestTandC
        case agreementInterestTransfer
        case readOnly
        case memo
        case largeTransactionWarning
        case feeSelection
        case errorNotice
        case invoiceCountdown
        case networkFee
    }
}
