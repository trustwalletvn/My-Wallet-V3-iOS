// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct InterestAccountLimits {

    // MARK: - Public Properties

    public let interestLockupDuration: Double
    public let cryptoCurrency: CryptoCurrency
    public let nextInterestPayment: Date
    public let minDepositAmount: FiatValue
    public let maxWithdrawalAmount: FiatValue

    // MARK: - Init

    public init(
        _ response: InterestLimits,
        cryptoCurrency: CryptoCurrency
    ) {
        interestLockupDuration = response.lockUpDuration
        self.cryptoCurrency = cryptoCurrency
        nextInterestPayment = Date()
        minDepositAmount = response.minDepositAmount
        maxWithdrawalAmount = response.maxWithdrawalAmount
    }
}

extension InterestAccountLimits {
    public var lockupDescription: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .short
        // NOTE: `lockUpDuration` is in seconds. Staging returns `Two Hours`.
        // So in Staging the value will show as `O Days`
        return formatter.string(from: TimeInterval(interestLockupDuration))?.capitalized ?? ""
    }
}
