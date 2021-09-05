// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Platform",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "PlatformKit", targets: ["PlatformKit"]),
        .library(name: "PlatformUIKit", targets: ["PlatformUIKit"]),
        .library(name: "PlatformKitMock", targets: ["PlatformKitMock"]),
        .library(name: "PlatformUIKitMock", targets: ["PlatformUIKitMock"])
    ],
    dependencies: [
        .package(name: "BigInt", url: "git@github.com:attaswift/BigInt.git", from: "5.2.1"),
        .package(name: "Charts", url: "git@github.com:danielgindi/Charts.git", from: "3.6.0"),
        .package(name: "DIKit", url: "git@github.com:jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(name: "RIBs", url: "git@github.com:paulo-bc/RIBs.git", from: "0.10.2"),
        .package(name: "RxCombine", url: "git@github.com:paulo-bc/RxCombine.git", from: "1.6.2"),
        .package(name: "RxDataSources", url: "git@github.com:RxSwiftCommunity/RxDataSources.git", from: "4.0.1"),
        .package(name: "RxSwift", url: "git@github.com:ReactiveX/RxSwift.git", from: "5.1.3"),
        .package(name: "Nuke", url: "https://github.com/kean/Nuke", from: "10.3.1"),
        .package(name: "PhoneNumberKit", url: "git@github.com:marmelroy/PhoneNumberKit.git", from: "3.3.3"),
        .package(name: "Zxcvbn", url: "git@github.com:oliveratkinson-bc/zxcvbn-ios.git", .branch("swift-package-manager")),
        .package(path: "../Analytics"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../CommonCrypto"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Tool"),
        .package(path: "../WalletPayload"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "PlatformKit",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxCombine", package: "RxCombine"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ],
            resources: [
                .copy("Services/Currencies/local-currencies-custodial.json")
            ]
        ),
        .target(
            name: "PlatformUIKit",
            dependencies: [
                "PlatformKit",
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxAnalyticsKit", package: "Analytics"),
                .product(name: "Charts", package: "Charts"),
                .product(name: "UIComponents", package: "UIComponents"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit"),
                .product(name: "Zxcvbn", package: "Zxcvbn")
            ],
            resources: [
                .copy("PlatformUIKitAssets.xcassets"),
                .copy("Views/TextView/MnemonicTextView/MnemonicTextView.xib"),
                .copy("Views/BottomSheetView/BottomSheetView.xib"),
                .copy("Views/BadgeView/BadgeView.xib"),
                .copy("Views/PrimaryButtonContainer/PrimaryButtonContainer.xib"),
                .copy("Views/AlertView/BottomAlertSheet.xib"),
                .copy("Views/InstructionTableView/InstructionTableViewCell.xib"),
                .copy("Views/TextField/TextFieldView.xib"),
                .copy("Views/SwitchView/SwitchView.xib"),
                .copy("Views/Cells/ButtonsTableViewCell/ButtonsTableViewCell.xib"),
                .copy("Components/AssetPriceView/AssetPriceView.xib"),
                .copy("Views/Cells/LineItemTableViewCell/LineItemTableViewCell.xib"),
                .copy("Foundation/InfoScreen/InfoScreenViewController.xib"),
                .copy("Components/WalletBalanceView/WalletBalanceView.xib"),
                .copy("Components/AccountPicker/AccountGroupBalanceCellI/AccountGroupBalanceTableViewCell.xib"),
                .copy("Components/AssetLineChart/AssetLineChartView/AssetLineChartView.xib"),
                .copy("Components/PriceAlertTableViewCell/PriceAlertTableViewCell.xib"),
                .copy("Components/MultiActionView/MultiActionView.xib"),
                .copy("Components/AssetLineChart/AssetLineChartTableViewCell/AssetLineChartTableViewCell.xib"),
                .copy("Components/MultiActionView/MultiActionTableViewCell/MultiActionTableViewCell.xib"),
                .copy("Components/DigitPad/DigitPadButtonView.xib"),
                .copy("Components/DigitPad/DigitPadView.xib"),
                .copy("Views/Cells/Badge/BadgeTableViewCell/BadgeTableViewCell.xib"),
                .copy("Components/SelectionScreen/SelectionScreenViewController.xib"),
                .copy("Components/Announcements/CardView/AnnouncementCardView.xib"),
                .copy("Components/SelectionScreen/TableHeaderView/SelectionScreenTableHeaderView.xib"),
                .copy("BuySellUIKit/Core/Components/LinkedCardTableViewCell/LinkedCardTableViewCell.xib"),
                .copy("BuySellUIKit/Core/IntroScreen/BuyIntro/BuyIntroScreenViewController.xib"),
                .copy("BuySellUIKit/Core/Components/LinkedCardView/LinkedCardView.xib"),
                .copy("Views/AlertView/AlertView.xib"),
                .copy("Loader/ActivityIndicatorLoaderView/ActivityIndicatorLoadingContainerView.xib"),
                .copy("BuySellUIKit/Core/Ineligible/IneligibleCurrency/IneligibleCurrencyViewController.xib"),
                .copy("BuySellUIKit/Core/Checkout/TransferCancellationScreen/TransferCancellationViewController.xib")
            ]
        ),
        .target(
            name: "PlatformKitMock",
            dependencies: [
                "PlatformKit"
            ]
        ),
        .target(
            name: "PlatformUIKitMock",
            dependencies: [
                "PlatformUIKit",
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: [
                "PlatformKit",
                "PlatformKitMock",
                .product(name: "NetworkKitMock", package: "Network"),
                .product(name: "ToolKitMock", package: "Tool")
            ],
            resources: [
                .copy("Fixtures/wallet-data.json")
            ]
        ),
        .testTarget(
            name: "PlatformUIKitTests",
            dependencies: [
                "PlatformKitMock",
                "PlatformUIKit",
                "PlatformUIKitMock"
            ]
        )
    ]
)
