// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import ToolKit

extension EnterAmountScreenPresenter.DisplayBundle {

    static var buy: EnterAmountScreenPresenter.DisplayBundle {

        typealias LocalizedString = LocalizationConstants.SimpleBuy.BuyCryptoScreen
        typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
        typealias NewAnalyticsEvent = AnalyticsEvents.New.SimpleBuy
        typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.BuyScreen

        return EnterAmountScreenPresenter.DisplayBundle(
            strings: Strings(
                title: LocalizedString.title,
                ctaButton: LocalizedString.ctaButton,
                bottomAuxiliaryItemSeparatorTitle: ""
            ),
            colors: Colors(
                digitPadTopSeparator: .lightBorder,
                bottomAuxiliaryItemSeparator: .lightBorder
            ),
            events: Events(
                didAppear: [AnalyticsEvent.sbBuyFormShown, NewAnalyticsEvent.buySellViewed(type: .buy)],
                confirmSuccess: AnalyticsEvent.sbBuyFormConfirmSuccess,
                confirmFailure: AnalyticsEvent.sbBuyFormConfirmFailure,
                confirmTapped: { currencyType, amount, cryptoType, additionalParameters in
                    [
                        AnalyticsEvent.sbBuyFormConfirmClick(
                            currencyCode: currencyType.code,
                            amount: amount.toDisplayString(includeSymbol: true),
                            additionalParameters: additionalParameters
                        ),
                        NewAnalyticsEvent.buyAmountEntered(
                            inputAmount: amount.displayMajorValue.doubleValue,
                            inputCurrency: currencyType.code,
                            maxCardLimit: nil,
                            outputCurrency: cryptoType.code
                        )
                    ]
                },
                sourceAccountChanged: { AnalyticsEvent.sbBuyFormCryptoChanged(asset: $0) }
            ),
            accessibilityIdentifiers: AccessibilityIdentifiers(
                bottomAuxiliaryItemSeparatorTitle: AccessibilityId.paymentMethodTitle
            ),
            amountDisplayBundle: .init(
                events: .init(
                    min: AnalyticsEvent.sbBuyFormMinClicked,
                    max: AnalyticsEvent.sbBuyFormMaxClicked
                ),
                strings: .init(
                    useMin: LocalizedString.LimitView.Buy.Min.useMin,
                    useMax: LocalizedString.LimitView.Buy.Max.useMax
                ),
                accessibilityIdentifiers: .init()
            )
        )
    }
}
