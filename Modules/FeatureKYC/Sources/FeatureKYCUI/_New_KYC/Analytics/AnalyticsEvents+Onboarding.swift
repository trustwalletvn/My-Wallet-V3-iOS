// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformUIKit

extension AnalyticsEvents.New {
    public enum Onboarding: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .nabu
        }

        case emailVerificationSkipped(origin: EmailVerificationOrigin)
        case emailVerificationRequested(origin: EmailVerificationOrigin)
        case upgradeVerificationClicked(origin: UpgradeVerificationOrigin, tier: Int)
        case walletSignedUp

        public enum EmailVerificationOrigin: String, StringRawRepresentable {
            case signUp = "SIGN_UP"
            case verification = "VERIFICATION"
        }

        public enum UpgradeVerificationOrigin: String, StringRawRepresentable {
            case airdrop = "AIRDROP"
            case dashboardPromo = "DASHBOARD_PROMO"
            case fiatFunds = "FIAT_FUNDS"
            case onboarding = "ONBOARDING"
            case resubmission = "RESUBMISSION"
            case savings = "SAVINGS"
            case settings = "SETTINGS"
            case simplebuy = "SIMPLEBUY"
            case simpletrade = "SIMPLETRADE"
            case swap = "SWAP"
            case unknown = "UNKNOWN"

            init(_ parentFlow: KYCParentFlow) {
                switch parentFlow {
                case .simpleBuy:
                    self = .simplebuy
                case .swap:
                    self = .swap
                case .settings:
                    self = .settings
                case .announcement:
                    self = .dashboardPromo
                case .resubmission:
                    self = .resubmission
                case .onboarding:
                    self = .onboarding
                case .receive:
                    self = .unknown
                case .airdrop:
                    self = .airdrop
                case .cash:
                    self = .fiatFunds
                }
            }
        }
    }
}
