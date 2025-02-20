// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureTransaction",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureTransaction",
            targets: ["FeatureTransactionDomain", "FeatureTransactionData", "FeatureTransactionUI"]
        ),
        .library(
            name: "FeatureTransactionDomain",
            targets: ["FeatureTransactionDomain"]
        ),
        .library(
            name: "FeatureTransactionData",
            targets: ["FeatureTransactionData"]
        ),
        .library(
            name: "FeatureTransactionUI",
            targets: ["FeatureTransactionUI"]
        ),
        .library(
            name: "FeatureTransactionDomainMock",
            targets: ["FeatureTransactionDomainMock"]
        ),
        .library(
            name: "FeatureTransactionUIMock",
            targets: ["FeatureTransactionUIMock"]
        )
    ],
    dependencies: [
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.24.0"
        ),
        .package(
            name: "Nuke",
            url: "https://github.com/kean/Nuke.git",
            from: "10.3.1"
        ),
        .package(
            name: "NukeUI",
            url: "https://github.com/kean/NukeUI.git",
            from: "0.6.5"
        ),
        .package(
            name: "BigInt",
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.1"
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
        .package(
            name: "RxDataSources",
            url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
            from: "4.0.1"
        ),
        .package(
            name: "RIBs",
            url: "https://github.com/paulo-bc/RIBs.git",
            from: "0.10.2"
        ),
        .package(path: "../Analytics"),
        .package(path: "../FeatureKYC"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureTransactionDomain",
            dependencies: [
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureTransactionData",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureTransactionUI",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "FeatureKYCDomain", package: "FeatureKYC"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "Nuke", package: "Nuke"),
                .product(name: "NukeUI", package: "NukeUI"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RIBs", package: "RIBs"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .target(
            name: "FeatureTransactionDomainMock",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .target(
            name: "FeatureTransactionUIMock",
            dependencies: [
                .target(name: "FeatureTransactionUI"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionDomainTests",
            dependencies: [
                .target(name: "FeatureTransactionDomain"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "PlatformKit", package: "Platform")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionDataTests",
            dependencies: [
                .target(name: "FeatureTransactionData")
            ]
        ),
        .testTarget(
            name: "FeatureTransactionUITests",
            dependencies: [
                .target(name: "FeatureTransactionDomainMock"),
                .target(name: "FeatureTransactionUI"),
                .target(name: "FeatureTransactionUIMock"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformKitMock", package: "Platform"),
                .product(name: "PlatformUIKitMock", package: "Platform"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
