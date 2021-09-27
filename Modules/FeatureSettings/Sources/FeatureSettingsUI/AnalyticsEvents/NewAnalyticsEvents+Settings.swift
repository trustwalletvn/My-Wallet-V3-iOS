// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum Settings: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case addMobileNumberClicked
        case changeMobileNumberClicked
        case notificationPreferencesUpdated(emailEnabled: Bool?, smsEnabled: Bool?)
        case settingsCurrencyClicked(currency: String)
        case settingsHyperlinkClicked(destination: Destination)

        enum Destination: String, StringRawRepresentable {
            case about = "ABOUT"
            case cookiesPolicy = "COOKIES_POLICY"
            case privacyPolicy = "PRIVACY_POLICY"
            case rateUs = "RATE_US"
            case termsOfService = "TERMS_OF_SERVICE"
        }
    }
}
