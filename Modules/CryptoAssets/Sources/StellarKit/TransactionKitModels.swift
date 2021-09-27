// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

enum StellarMemo {
    case id(UInt64)
    case text(String)
}

struct SendDetails {
    let fromAddress: String
    let fromLabel: String
    let toAddress: String
    let toLabel: String
    let value: CryptoValue
    let fee: CryptoValue
    let memo: StellarMemo?
}

enum SendFailureReason: Error {
    case unknown
    case belowMinimumSend
    case belowMinimumSendNewAccount
    case insufficientFunds
    case badDestinationAccountID
}

struct SendConfirmationDetails {
    let sendDetails: SendDetails
    let fees: CryptoValue
    let transactionHash: String
}
