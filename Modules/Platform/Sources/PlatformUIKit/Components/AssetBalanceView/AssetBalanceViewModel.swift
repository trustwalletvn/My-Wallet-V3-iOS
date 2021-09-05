// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit

public enum AssetBalanceViewModel {

    // MARK: - State Aliases

    public enum State {
        /// The state of the `AssetBalance` interactor and presenter
        public typealias Interaction = LoadingState<Value.Interaction>
        public typealias Presentation = LoadingState<Value.Presentation>
    }

    // MARK: - Value Namespace

    public enum Value {

        // MARK: - Interaction

        /// The interaction value of asset
        public struct Interaction {
            /// The wallet's balance in fiat
            let fiatValue: MoneyValue
            /// The wallet's balance in crypto
            let cryptoValue: MoneyValue
            /// The wallet's pending balance in crypto
            let pendingValue: MoneyValue

            init(
                fiatValue: MoneyValue,
                cryptoValue: MoneyValue,
                pendingValue: MoneyValue
            ) {
                self.fiatValue = fiatValue
                self.cryptoValue = cryptoValue
                self.pendingValue = pendingValue
            }
        }

        // MARK: - Presentation

        public struct Presentation {

            private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

            // MARK: - Properties

            /// The balance in fiat
            let fiatBalance: LabelContent

            /// The balance in crypto
            let cryptoBalance: LabelContent

            /// The visibility state of the `Pending` balance
            let pendingBalanceVisibility: Visibility

            /// The pending balance in crypto. This value is `.none`
            /// should the user's pending balance be `.zero`
            let pendingBalance: LabelContent

            /// Descriptors that allows customized content and style
            public struct Descriptors {
                let fiatFont: UIFont
                let fiatTextColor: UIColor
                let fiatAccessibility: Accessibility
                let cryptoFont: UIFont
                let cryptoTextColor: UIColor
                let pendingTextColor: UIColor
                let cryptoAccessibility: Accessibility

                public init(
                    fiatFont: UIFont,
                    fiatTextColor: UIColor,
                    fiatAccessibility: Accessibility,
                    cryptoFont: UIFont,
                    cryptoTextColor: UIColor,
                    pendingTextColor: UIColor = .mutedText,
                    cryptoAccessibility: Accessibility
                ) {
                    self.fiatFont = fiatFont
                    self.fiatTextColor = fiatTextColor
                    self.fiatAccessibility = fiatAccessibility
                    self.cryptoFont = cryptoFont
                    self.cryptoTextColor = cryptoTextColor
                    self.cryptoAccessibility = cryptoAccessibility
                    self.pendingTextColor = pendingTextColor
                }
            }

            // MARK: - Setup

            public init(with value: Interaction, alignment: UIStackView.Alignment, descriptors: Descriptors) {
                let textAlignment: NSTextAlignment
                switch alignment {
                case .leading:
                    textAlignment = .left
                case .trailing:
                    textAlignment = .right
                default:
                    textAlignment = .natural
                }
                fiatBalance = LabelContent(
                    text: value.fiatValue.toDisplayString(includeSymbol: true, locale: .current),
                    font: descriptors.fiatFont,
                    color: descriptors.fiatTextColor,
                    alignment: textAlignment,
                    accessibility: descriptors.fiatAccessibility.with(idSuffix: value.cryptoValue.currencyType.code)
                )

                if value.cryptoValue == value.fiatValue {
                    cryptoBalance = .empty
                } else {
                    cryptoBalance = LabelContent(
                        text: value.cryptoValue.toDisplayString(includeSymbol: true, locale: .current),
                        font: descriptors.cryptoFont,
                        color: descriptors.cryptoTextColor,
                        alignment: textAlignment,
                        accessibility: descriptors.cryptoAccessibility.with(idSuffix: value.cryptoValue.currencyType.code)
                    )
                }
                pendingBalanceVisibility = value.pendingValue.isZero ? .hidden : .visible
                pendingBalance = LabelContent(
                    text: value.pendingValue.toDisplayString(includeSymbol: true, locale: .current),
                    font: descriptors.cryptoFont,
                    color: descriptors.pendingTextColor,
                    alignment: textAlignment,
                    accessibility: descriptors.cryptoAccessibility.with(idSuffix: value.cryptoValue.currencyType.code)
                )
            }
        }
    }
}

extension AssetBalanceViewModel.Value.Presentation.Descriptors {
    public typealias Descriptors = AssetBalanceViewModel.Value.Presentation.Descriptors

    public static func `default`(
        cryptoAccessiblitySuffix: String,
        fiatAccessiblitySuffix: String
    ) -> Descriptors {
        Descriptors(
            fiatFont: .main(.semibold, 16.0),
            fiatTextColor: .dashboardFiatPriceTitle,
            fiatAccessibility: .id(fiatAccessiblitySuffix),
            cryptoFont: .main(.medium, 14.0),
            cryptoTextColor: .descriptionText,
            cryptoAccessibility: .id(cryptoAccessiblitySuffix)
        )
    }

    public static func muted(
        cryptoAccessiblitySuffix: String,
        fiatAccessiblitySuffix: String
    ) -> Descriptors {
        Descriptors(
            fiatFont: .main(.medium, 16.0),
            fiatTextColor: .mutedText,
            fiatAccessibility: .id(fiatAccessiblitySuffix),
            cryptoFont: .main(.medium, 14.0),
            cryptoTextColor: .mutedText,
            cryptoAccessibility: .id(cryptoAccessiblitySuffix)
        )
    }

    public static func activity(
        cryptoAccessiblitySuffix: String,
        fiatAccessiblitySuffix: String
    ) -> Descriptors {
        Descriptors(
            fiatFont: .main(.semibold, 16.0),
            fiatTextColor: .textFieldText,
            fiatAccessibility: .id(fiatAccessiblitySuffix),
            cryptoFont: .main(.medium, 14.0),
            cryptoTextColor: .descriptionText,
            cryptoAccessibility: .id(cryptoAccessiblitySuffix)
        )
    }
}
