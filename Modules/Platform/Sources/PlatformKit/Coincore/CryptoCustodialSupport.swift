// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct CryptoCustodialSupport {
    public static let empty: CryptoCustodialSupport = .init(data: [:])

    public struct Actions {
        private enum Keys: String {
            case canBuy = "CanBuy" // Brokerage support - simple buy
            case canSell = "CanSell" // Brokerage support - simple sell
            case canSwap = "CanSwap" // Brokerage support - can swap
            case canSend = "CanSend"
            case canReceive = "CanReceive"
            // Multi-flags
            case fullSupport = "FullSupport" // == CanSend & CanReceive & CanBuy & CanSell & CanSwap
            case sendReceive = "SendReceive" // == CanSend & CanReceive
            case brokerage = "Brokerage" // == CanBuy & CanSell & CanSwap
            case canBuySell = "CanBuySell" // == CanBuy & CanSell
        }

        public var canBuy: Bool {
            keys.contains(.canBuy)
                || keys.contains(.canBuySell)
                || keys.contains(.brokerage)
                || keys.contains(.fullSupport)
        }

        public var canSell: Bool {
            keys.contains(.canSell)
                || keys.contains(.canBuySell)
                || keys.contains(.brokerage)
                || keys.contains(.fullSupport)
        }

        public var canSwap: Bool {
            keys.contains(.canSwap)
                || keys.contains(.brokerage)
                || keys.contains(.fullSupport)
        }

        public var canSend: Bool {
            keys.contains(.canSend)
                || keys.contains(.sendReceive)
                || keys.contains(.fullSupport)
        }

        public var canReceive: Bool {
            keys.contains(.canReceive)
                || keys.contains(.sendReceive)
                || keys.contains(.fullSupport)
        }

        private let keys: [Keys]

        init(data: [String]) {
            keys = data.compactMap(Keys.init)
        }
    }

    public let data: [String: Actions]

    public init(data: [String: [String]]) {
        self.data = data.compactMapValues(Actions.init)
    }
}
