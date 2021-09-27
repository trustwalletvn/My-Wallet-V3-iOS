// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public enum FeeState: Equatable {
    case feeTooHigh
    case feeUnderMinLimit
    case feeUnderRecommended
    case feeOverRecommended
    case validCustomFee
    case valid(absoluteFee: MoneyValue)
}
