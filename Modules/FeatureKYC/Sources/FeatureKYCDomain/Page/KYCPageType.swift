// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum KYCPageType: Int {
    // Need to set the first enumeration as 1. The order of these enums also matter
    // since KycSettings.latestKycPage will look at the rawValue of the enum when
    // the latestKycPage is set.
    case welcome = 1
    case enterEmail
    case confirmEmail
    case country
    case states
    case profile
    case address
    case tier1ForcedTier2
    case enterPhone
    case confirmPhone
    case verifyIdentity
    case resubmitIdentity
    case applicationComplete
    case accountStatus
    case sddVerificationCheck // adding it here as in-progress KYC flows are cached
}
