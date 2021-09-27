// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit

private class WithdrawAnalyticsEvent: AnalyticsEvent {
    var name: String = ""
}

extension DisplayBundle {

    static func withdraw(sourceAccount: SingleAccount) -> DisplayBundle {
        typealias LocalizedString = LocalizationConstants.Transaction

        return DisplayBundle(
            title: LocalizedString.Withdraw.withdraw + " \(sourceAccount.currencyType.code)",
            amountDisplayBundle: .init(
                events: .init(
                    min: WithdrawAnalyticsEvent(),
                    max: WithdrawAnalyticsEvent()
                ),
                strings: .init(
                    useMin: LocalizedString.Swap.AmountPresenter.LimitView.useMin,
                    useMax: LocalizedString.Swap.AmountPresenter.LimitView.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
