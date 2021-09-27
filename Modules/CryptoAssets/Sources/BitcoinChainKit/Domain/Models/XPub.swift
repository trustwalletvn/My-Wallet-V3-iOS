// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A collection of XPub addresses.
public struct XPubs {
    public let xpubs: [XPub]

    public var `default`: XPub {
        bech32 ?? legacy
    }

    private var bech32: XPub? {
        xpubs.first { $0.derivationType == .bech32 }
    }

    private var legacy: XPub! {
        xpubs.first { $0.derivationType == .legacy }
    }

    public init(xpubs: [XPub]) {
        self.xpubs = xpubs
    }
}

/// A single XPub address.
public struct XPub: Hashable {
    public let address: String
    public let derivationType: DerivationType

    public init(address: String, derivationType: DerivationType) {
        self.address = address
        self.derivationType = derivationType
    }
}

public enum DerivationType: String, Decodable {
    case legacy
    case bech32
}
