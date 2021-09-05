// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum SecondPasswordScreen {
        static let title = NSLocalizedString(
            "Second Password Detected",
            comment: "Second Password Screen main title"
        )

        static let description = NSLocalizedString(
            "We’re moving away from 2nd passwords.\nTo use the mobile app, log in on web to enable 2FA.",
            comment: "Second Password Screen description"
        )

        static let learnMore = NSLocalizedString(
            "Learn More",
            comment: "Second Password Screen learn more text link"
        )

        static let loginOnWebButtonTitle = NSLocalizedString(
            "Log In with Browser",
            comment: "Second Password Screen button link"
        )
    }
}
