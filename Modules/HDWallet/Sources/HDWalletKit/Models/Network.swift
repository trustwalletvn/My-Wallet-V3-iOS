// Copyright © Blockchain Luxembourg S.A. All rights reserved.

protocol CoinType {
    static var coinType: UInt32 { get }
}

// TODO:
// * Move to BitcoinKit
// * Is this the right design???
struct Bitcoin: CoinType {
    static let coinType: UInt32 = 0
}

struct Blockstack: CoinType {
    static let coinType: UInt32 = 5757
}

// TODO:
// * For now `CoinType` is not supported by LibWally-Swift,
enum Network {
    case main(CoinType.Type)
    case test
}
