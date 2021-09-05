// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension KYC {
    /**
     Read about [Service Nabu Core - KYC Tiers](https://github.com/blockchain/service-nabu-core/wiki/Kyc-Tiers) and [Service Nabu Core - KYC Lifecycle](https://github.com/blockchain/service-nabu-core/wiki/KYC-Lifecycle)
     */
    public enum AccountStatus: String, Codable {
        case none = "NONE"
        case pending = "PENDING"
        case underReview = "UNDER_REVIEW"
        case failed = "REJECTED"
        case approved = "VERIFIED"
        case expired = "EXPIRED"

        public var isInProgress: Bool {
            self == .pending || self == .underReview
        }

        public var isApproved: Bool {
            self == .approved
        }

        public var isInProgressOrApproved: Bool {
            isInProgress || isApproved
        }
    }
}
