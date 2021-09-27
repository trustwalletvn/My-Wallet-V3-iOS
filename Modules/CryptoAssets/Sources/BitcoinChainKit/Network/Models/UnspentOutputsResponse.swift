// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct UnspentOutputsResponse: Codable {

    public let unspent_outputs: [UnspentOutputResponse]

    init(unspent_outputs: [UnspentOutputResponse]) {
        self.unspent_outputs = unspent_outputs
    }
}

public struct UnspentOutputResponse: Codable {

    public struct XPub: Codable {
        public let m: String
        public let path: String
    }

    public let tx_hash: String
    public let script: String
    public let value: Decimal
    public let confirmations: UInt
    public let xpub: XPub
    public let tx_index: Int
    public let replayable: Bool?
}
