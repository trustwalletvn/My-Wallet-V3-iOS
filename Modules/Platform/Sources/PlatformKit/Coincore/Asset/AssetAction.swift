// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum AssetAction: Equatable {
    case viewActivity
    case deposit
    case buy
    case sell
    case send
    case receive
    case swap
    case withdraw
}

extension AssetAction: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        switch self {
        case .viewActivity:
            return "viewActivity"
        case .deposit:
            return "deposit"
        case .buy:
            return "buy"
        case .sell:
            return "sell"
        case .send:
            return "send"
        case .receive:
            return "receive"
        case .swap:
            return "swap"
        case .withdraw:
            return "withdraw"
        }
    }

    public var debugDescription: String {
        description
    }
}
