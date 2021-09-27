// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct TransactionLimits {

    public var maxTradableToday: FiatValue {
        daily?.available ?? maxPossibleOrder
    }

    public let currency: FiatCurrency
    public let minOrder: FiatValue
    public let maxOrder: FiatValue
    public let maxPossibleOrder: FiatValue
    public let daily: TransactionLimit?
    public let weekly: TransactionLimit?
    public let annual: TransactionLimit?

    public init(
        currency: FiatCurrency,
        minOrder: FiatValue,
        maxOrder: FiatValue,
        maxPossibleOrder: FiatValue,
        daily: TransactionLimit?,
        weekly: TransactionLimit?,
        annual: TransactionLimit?
    ) {
        self.currency = currency
        self.minOrder = minOrder
        self.maxOrder = maxOrder
        self.maxPossibleOrder = maxPossibleOrder
        self.daily = daily
        self.weekly = weekly
        self.annual = annual
    }
}
