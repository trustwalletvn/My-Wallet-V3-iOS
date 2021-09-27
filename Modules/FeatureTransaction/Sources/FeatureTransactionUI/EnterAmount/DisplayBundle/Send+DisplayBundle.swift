// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

private class SendAnalyticsEvent: AnalyticsEvent {
    var name: String = ""
}

extension DisplayBundle {

    static func send(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Transaction

        return DisplayBundle(
            title: LocalizedString.Send.send,
            amountDisplayBundle: .init(
                events: .init(
                    min: SendAnalyticsEvent(),
                    max: SendAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.Send.AmountPresenter.LimitView.useMin,
                    useMax: LocalizedString.Send.AmountPresenter.LimitView.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
