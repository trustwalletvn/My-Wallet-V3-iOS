// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit

public enum DashboardAsset {

    // MARK: - State Aliases

    public enum State {

        /// The state of the `AssetPrice` interactor and presenter
        public enum AssetPrice {
            public typealias Interaction = LoadingState<Value.Interaction.AssetPrice>
            public typealias Presentation = LoadingState<Value.Presentation.AssetPrice>
        }
    }

    // MARK: - Value Namespace

    public enum Value {

        // MARK: - Interaction

        /// The interaction value of dashboard asset
        public enum Interaction {

            public struct AssetPrice {

                /// Time unit. Can be further customized in future
                /// Each value currently refers to 1 unit
                public enum Time {
                    case hours(Int)
                    case days(Int)
                    case weeks(Int)
                    case months(Int)
                    case years(Int)
                    case timestamp(Date)
                    case all

                    var string: String {
                        switch self {
                        case .hours(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.hours : LocalizationConstants.TimeUnit.Singular.hour
                            return "\(number) \(time)"
                        case .days(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.days : LocalizationConstants.TimeUnit.Singular.day
                            return "\(number) \(time)"
                        case .weeks(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.weeks : LocalizationConstants.TimeUnit.Singular.week
                            return "\(number) \(time)"
                        case .months(let number):
                            let time = number > 1 ? LocalizationConstants.TimeUnit.Plural.months : LocalizationConstants.TimeUnit.Singular.month
                            return "\(number) \(time)"
                        case .years(let number):
                            switch number > 1 {
                            case true:
                                return LocalizationConstants.TimeUnit.Plural.allTime
                            case false:
                                return "\(number) \(LocalizationConstants.TimeUnit.Singular.year)"
                            }
                        case .timestamp(let date):
                            return DateFormatter.medium.string(from: date)
                        case .all:
                            return LocalizationConstants.TimeUnit.Plural.allTime
                        }
                    }
                }

                /// The `Time` for the given `AssetPrice`
                let time: Time

                /// The asset price in localized fiat currency
                let fiatValue: FiatValue

                /// Percentage of change since a certain time
                let changePercentage: Double

                /// The change in fiat value
                let fiatChange: FiatValue

                public init(time: Time, fiatValue: FiatValue, changePercentage: Double, fiatChange: FiatValue) {
                    self.time = time
                    self.fiatValue = fiatValue
                    self.changePercentage = changePercentage
                    self.fiatChange = fiatChange
                }
            }
        }

        // MARK: - Presentation

        public enum Presentation {

            /// The presentation model for `AssetPriceView`
            public struct AssetPrice: CustomDebugStringConvertible {

                private typealias AccessibilityId = Accessibility.Identifier.Dashboard.AssetCell

                /// Descriptors that allows customized content and style
                public struct Descriptors {

                    /// Options to display content
                    struct ContentOptions: OptionSet {
                        let rawValue: Int

                        init(rawValue: Int) {
                            self.rawValue = rawValue
                        }

                        /// Includes fiat price change
                        static let fiat = ContentOptions(rawValue: 1 << 0)

                        /// Includes percentage price change
                        static let percentage = ContentOptions(rawValue: 2 << 0)
                    }

                    let contentOptions: ContentOptions
                    let priceFont: UIFont
                    let changeFont: UIFont
                    let accessibilityIdSuffix: String
                }

                // MARK: - Properties

                /// The price of the asset
                let price: LabelContent

                /// The change
                let change: NSAttributedString

                let changeAccessibility: Accessibility

                public var debugDescription: String {
                    price.text + " " + change.string
                }

                // MARK: - Setup

                public init(with value: Interaction.AssetPrice, descriptors: Descriptors) {
                    let fiatPrice = value.fiatValue.toDisplayString(includeSymbol: true)
                    price = LabelContent(
                        text: fiatPrice,
                        font: descriptors.priceFont,
                        color: .dashboardAssetTitle,
                        accessibility: .id("\(AccessibilityId.marketFiatBalanceLabelFormat)\(descriptors.accessibilityIdSuffix)")
                    )

                    let fiatTintColor: UIColor
                    var deltaTintColor: UIColor
                    let sign: String
                    if value.fiatChange.isPositive {
                        sign = "+"
                        fiatTintColor = .positivePrice
                    } else if value.fiatChange.isNegative {
                        sign = ""
                        fiatTintColor = .negativePrice
                    } else {
                        sign = ""
                        fiatTintColor = .mutedText
                    }
                    deltaTintColor = value.changePercentage > 0 ? .positivePrice : .negativePrice
                    deltaTintColor = value.changePercentage.isZero ? .mutedText : deltaTintColor

                    let fiatChange: NSAttributedString
                    if descriptors.contentOptions.contains(.fiat) {
                        let fiat = value.fiatChange.toDisplayString(includeSymbol: true)
                        let suffix = descriptors.contentOptions.contains(.percentage) ? " " : ""
                        fiatChange = NSAttributedString(
                            LabelContent(
                                text: "\(sign)\(fiat)\(suffix)",
                                font: descriptors.changeFont,
                                color: fiatTintColor
                            )
                        )
                    } else {
                        fiatChange = NSAttributedString()
                    }

                    let percentageChange: NSAttributedString
                    if descriptors.contentOptions.contains(.percentage) {
                        let prefix: String
                        let suffix: String
                        if descriptors.contentOptions.contains(.fiat) {
                            prefix = "("
                            suffix = ")"
                        } else {
                            prefix = ""
                            suffix = ""
                        }
                        let percentage = value.changePercentage * 100
                        let percentageString = percentage.string(with: 2)
                        percentageChange = NSAttributedString(
                            LabelContent(
                                text: "\(prefix)\(percentageString)%\(suffix)",
                                font: descriptors.changeFont,
                                color: deltaTintColor
                            )
                        )
                    } else {
                        percentageChange = NSAttributedString()
                    }

                    let period = NSAttributedString(
                        LabelContent(
                            text: " \(value.time.string)",
                            font: descriptors.changeFont,
                            color: .mutedText
                        )
                    )
                    change = fiatChange + percentageChange + period
                    changeAccessibility = .id("\(AccessibilityId.changeLabelFormat)\(descriptors.accessibilityIdSuffix)")
                }
            }
        }
    }
}

extension DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
    /// Returns a descriptor for dashboard total balance
    public static var balance: DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        .init(
            contentOptions: [.fiat, .percentage],
            priceFont: .main(.semibold, 24.0),
            changeFont: .main(.medium, 14.0),
            accessibilityIdSuffix: Accessibility.Identifier.Dashboard.TotalBalanceCell.valueLabelSuffix
        )
    }

    /// Returns a descriptor for dashboard asset price
    public static func assetPrice(
        accessibilityIdSuffix: String,
        priceFontSize: CGFloat = 16.0,
        changeFontSize: CGFloat = 14.0
    ) -> DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        .init(
            contentOptions: [.percentage],
            priceFont: .main(.semibold, priceFontSize),
            changeFont: .main(.medium, changeFontSize),
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }

    /// Returns a descriptor for widget asset price
    public static func widget(accessibilityIdSuffix: String) -> DashboardAsset.Value.Presentation.AssetPrice.Descriptors {
        .init(
            contentOptions: [.fiat],
            priceFont: .systemFont(ofSize: 16.0, weight: .semibold),
            changeFont: .systemFont(ofSize: 12.0, weight: .semibold),
            accessibilityIdSuffix: accessibilityIdSuffix
        )
    }
}

extension PriceWindow {

    public typealias Time = DashboardAsset.Value.Interaction.AssetPrice.Time

    public func time(for currency: CryptoCurrency) -> Time {
        switch self {
        case .all:
            return .all
        case .year:
            return .years(1)
        case .month:
            return .months(1)
        case .week:
            return .weeks(1)
        case .day:
            return .hours(24)
        }
    }
}
