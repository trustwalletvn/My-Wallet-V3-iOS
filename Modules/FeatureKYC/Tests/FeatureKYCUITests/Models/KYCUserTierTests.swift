// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
import Localization
import PlatformKit
import XCTest

class KYCUserTierTests: XCTestCase {
    func testLockedState() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .none)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .none)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        XCTAssertNil(badgeModel)
    }

    func testTier1Pending() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .pending)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .none)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierOneVerification + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testTier1Verified() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .verified)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .none)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierOneVerification + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testTier1PendingTier2Pending() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .pending)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .pending)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierTwoVerification + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testTier1VerifiedTier2Pending() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .verified)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .pending)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierTwoVerification + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testTier1FailedTier2Pending() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .rejected)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .pending)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierTwoVerification + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testTier2Verified() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .none)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .verified)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierTwoVerification + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testTier1PendingTier2Verified() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .pending)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .verified)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierTwoVerification + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func testVerifiedState() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .verified)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .verified)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierTwoVerification + " - " + LocalizationConstants.KYC.accountApprovedBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func tier2Pending() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .none)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .pending)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierTwoVerification + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }

    func tier1Rejected() {
        let userTier1 = KYC.UserTier(tier: .tier1, state: .rejected)
        let userTier2 = KYC.UserTier(tier: .tier2, state: .none)
        let response = KYC.UserTiers(tiers: [userTier1, userTier2])
        let badgeModel = KYCUserTiersBadgeModel(response: response)
        let title = LocalizationConstants.KYC.tierOneVerification + " - " + LocalizationConstants.KYC.accountInReviewBadge
        XCTAssertTrue(badgeModel?.text == title)
    }
}

extension KYC.UserTier {
    fileprivate static let tier1Rejected = KYC.UserTier(tier: .tier1, state: .rejected)
    fileprivate static let tier2Rejected = KYC.UserTier(tier: .tier2, state: .rejected)

    fileprivate static let tier1Approved = KYC.UserTier(tier: .tier1, state: .verified)
    fileprivate static let tier2Approved = KYC.UserTier(tier: .tier2, state: .verified)

    fileprivate static let tier1Pending = KYC.UserTier(tier: .tier1, state: .pending)
    fileprivate static let tier2Pending = KYC.UserTier(tier: .tier2, state: .pending)

    fileprivate static let tier1None = KYC.UserTier(tier: .tier1, state: .none)
    fileprivate static let tier2None = KYC.UserTier(tier: .tier2, state: .none)
}
