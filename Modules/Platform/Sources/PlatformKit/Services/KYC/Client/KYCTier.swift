// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension KYC.Tier {

    public var headline: String? {
        switch self {
        case .tier2:
            return LocalizationConstants.KYC.freeCrypto
        case .tier0,
             .tier1:
            return nil
        }
    }

    public var tierDescription: String {
        switch self {
        case .tier0:
            return "Tier Zero Verification"
        case .tier1:
            return LocalizationConstants.KYC.tierOneVerification
        case .tier2:
            return LocalizationConstants.KYC.tierTwoVerification
        }
    }

    public var requirementsDescription: String {
        switch self {
        case .tier1:
            return LocalizationConstants.KYC.tierOneRequirements
        case .tier2:
            return LocalizationConstants.KYC.tierTwoRequirements
        case .tier0:
            return ""
        }
    }

    public var limitTimeframe: String {
        switch self {
        case .tier0:
            return "locked"
        case .tier1:
            return LocalizationConstants.KYC.annualSwapLimit
        case .tier2:
            return LocalizationConstants.KYC.dailySwapLimit
        }
    }

    public var duration: String {
        switch self {
        case .tier0:
            return "0 minutes"
        case .tier1:
            return LocalizationConstants.KYC.takesThreeMinutes
        case .tier2:
            return LocalizationConstants.KYC.takesTenMinutes
        }
    }
}
