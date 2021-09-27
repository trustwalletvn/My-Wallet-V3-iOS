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
        .package(
            name: "BigInt",
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.1"
        ),
        .package(
            name: "Charts",
            url: "https://github.com/danielgindi/Charts.git",
            from: "3.6.0"
        ),
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "RIBs",
            url: "https://github.com/paulo-bc/RIBs.git",
            from: "0.10.2"
        ),
        .package(
            name: "RxCombine",
            url: "https://github.com/paulo-bc/RxCombine.git",
            from: "1.6.2"
        ),
        .package(
            name: "RxDataSources",
            url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
            from: "4.0.1"
        ),
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
        .package(
            name: "Nuke",
            url: "https://github.com/kean/Nuke.git",
            from: "10.3.1"
        ),
        .package(
            name: "PhoneNumberKit",
            url: "https://github.com/marmelroy/PhoneNumberKit.git",
            from: "3.3.3"
        ),
        .package(
            name: "Zxcvbn",
            url: "https://github.com/oliveratkinson-bc/zxcvbn-ios.git",
            .branch("swift-package-manager")
        ),
        .package(path: "../Analytics"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../CommonCrypto"),
        .package(path: "../Localization"),
        .package(path: "../Network"),
        .package(path: "../Test"),
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
                .target(name: "PlatformKit"),
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
                .copy("PlatformUIKitAssets.xcassets")
            ]
        ),
        .target(
            name: "PlatformKitMock",
            dependencies: [
                .target(name: "PlatformKit")
            ]
        ),
        .target(
            name: "PlatformUIKitMock",
            dependencies: [
                .target(name: "PlatformUIKit"),
                .product(name: "AnalyticsKitMock", package: "Analytics"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        ),
        .testTarget(
            name: "PlatformKitTests",
            dependencies: [
                .target(name: "PlatformKit"),
                .target(name: "PlatformKitMock"),
                .product(name: "NetworkKitMock", package: "Network"),
                .product(name: "ToolKitMock", package: "Tool"),
                .product(name: "TestKit", package: "Test")
            ],
            resources: [
                .copy("Fixtures/wallet-data.json")
            ]
        ),
        .testTarget(
            name: "PlatformUIKitTests",
            dependencies: [
                .target(name: "PlatformKitMock"),
                .target(name: "PlatformUIKit"),
                .target(name: "PlatformUIKitMock"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
