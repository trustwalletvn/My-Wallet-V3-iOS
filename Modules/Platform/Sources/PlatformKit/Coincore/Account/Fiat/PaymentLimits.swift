// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PaymentLimits {

    public var fiatCurrency: FiatCurrency {
        min.currency.fiatCurrency!
    }

    public struct Max {
        public let transactional: FiatValue
        public let daily: FiatValue
        public let annual: FiatValue

        public init(
            transactional: FiatValue,
            daily: FiatValue,
            annual: FiatValue
        ) {
            self.transactional = transactional
            self.daily = daily
            self.annual = annual
        }
    }

    /// Derived from your `paymentMethod.limits.min`
    public let min: FiatValue
    /// Derived from your `paymentMethod.daily?.available` or
    /// your `paymentMethod.limits.max`
    public let max: Max

    public init(
        min: FiatValue,
        max: Max
    ) {
        self.min = min
        self.max = max
    }
}
