// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureAuthentication",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "FeatureAuthentication",
            targets: ["FeatureAuthenticationData", "FeatureAuthenticationDomain", "FeatureAuthenticationUI"]
        ),
        .library(
            name: "FeatureAuthenticationDomain",
            targets: ["FeatureAuthenticationDomain"]
        ),
        .library(
            name: "FeatureAuthenticationMock",
            targets: ["FeatureAuthenticationMock"]
        )
    ],
    dependencies: [
        .package(
            name: "Zxcvbn",
            url: "https://github.com/oliveratkinson-bc/zxcvbn-ios.git",
            .branch("swift-package-manager")
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "swift-composable-architecture",
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "0.18.0"
        ),
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
        .package(path: "../Analytics"),
        .package(path: "../HDWallet"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Test"),
        .package(path: "../Tool"),
        .package(path: "../UIComponents"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "FeatureAuthenticationDomain",
            dependencies: [
                .product(name: "HDWalletKit", package: "HDWallet"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "Zxcvbn", package: "Zxcvbn")
            ]
        ),
        .target(
            name: "FeatureAuthenticationData",
            dependencies: [
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureAuthenticationUI",
            dependencies: [
                .target(name: "FeatureAuthenticationDomain"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Localization", package: "Localization"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "UIComponents", package: "UIComponents")
            ]
        ),
        .target(
            name: "FeatureAuthenticationMock",
            dependencies: [
                .target(name: "FeatureAuthenticationDomain"),
                .target(name: "FeatureAuthenticationData")
            ]
        ),
        .testTarget(
            name: "FeatureAuthenticationDataTests",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationMock"),
                .product(name: "RxBlocking", package: "RxSwift")
            ]
        ),
        .testTarget(
            name: "FeatureAuthenticationUITests",
            dependencies: [
                .target(name: "FeatureAuthenticationData"),
                .target(name: "FeatureAuthenticationMock"),
                .target(name: "FeatureAuthenticationUI"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
