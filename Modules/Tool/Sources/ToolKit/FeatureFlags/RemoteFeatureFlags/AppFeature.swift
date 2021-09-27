// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates app features that can be dynamically configured (e.g. enabled/disabled)
public enum AppFeature: Int, CaseIterable {

    // MARK: - Local features

    case biometry

    // MARK: - Firebase features

    /// The announcements
    case announcements

    /// The announcements
    case announcementAsset

    /// Sift Science SDK is enabled
    case siftScienceEnabled

    /// Enable Secure Channel
    case secureChannel

    // MARK: Onboarding (After Login)

    /// Shows Email Verification insted of Simple Buy at Login
    case showOnboardingAfterSignUp

    /// Shows Email Verification in Onboarding, otherwise just show the buy flow
    case showEmailVerificationInOnboarding

    /// Shows Email Verification, if needed, when a user tries to make a purchase
    case showEmailVerificationInBuyFlow

    // MARK: SDD

    /// Enables SDD checks. If `false`, all checks immediately fail
    case sddEnabled

    /// Enable ACH withdraw and deposit
    case withdrawAndDepositACH

    /// Enable interest withdraw and deposit
    case interestWithdrawAndDeposit
}

extension AppFeature {
    /// The remote key which determines if this feature is enabled or not
    public var remoteEnabledKey: String? {
        switch self {
        case .interestWithdrawAndDeposit:
            return "ios_interest_deposit_withdraw"
        case .announcements:
            return "announcements"
        case .announcementAsset:
            return "new_asset_announcement_ticker"
        case .siftScienceEnabled:
            return "sift_science_enabled"
        case .secureChannel:
            return "secure_channel_ios"
        case .withdrawAndDepositACH:
            return "ach_withdraw_deposit_enabled"
        case .biometry:
            return nil
        case .showOnboardingAfterSignUp:
            return "show_onboarding_after_sign_up_ios"
        case .showEmailVerificationInOnboarding:
            return "show_email_verification_in_onboarding_ios"
        case .showEmailVerificationInBuyFlow:
            return "show_email_verification_in_buy_flow_ios"
        case .sddEnabled:
            return "sdd_enabled_ios"
        }
    }

    /// Enables the feature for alpha release by overriding remote config settings.
    var isAlphaReady: Bool {
        switch self {
        case .announcementAsset:
            return false
        case .interestWithdrawAndDeposit:
            return false
        case .announcements:
            return false
        case .siftScienceEnabled:
            return false
        case .secureChannel:
            return false
        case .withdrawAndDepositACH:
            return false
        case .biometry:
            return false
        case .showOnboardingAfterSignUp:
            return false
        case .showEmailVerificationInOnboarding:
            return false
        case .showEmailVerificationInBuyFlow:
            return false
        case .sddEnabled:
            return false
        }
    }
}
