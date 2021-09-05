// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "WalletPayload",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "WalletPayloadKit", targets: ["WalletPayloadKit"]),
        .library(name: "WalletPayloadKitMock", targets: ["WalletPayloadKitMock"])
    ],
    dependencies: [
        .package(url: "git@github.com:ReactiveX/RxSwift.git", from: "5.1.3"),
        .package(url: "git@github.com:jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(path: "../Localization"),
        .package(path: "../CommonCrypto"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "WalletPayloadKit",
            dependencies: [
                .product(name: "Localization", package: "Localization"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "DIKit", package: "DIKit")
            ]
        ),
        .target(
            name: "WalletPayloadKitMock",
            dependencies: [
                "WalletPayloadKit",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ]
        ),
        .testTarget(
            name: "WalletPayloadKitTests",
            dependencies: [
                "WalletPayloadKit",
                "WalletPayloadKitMock",
                .product(name: "ToolKitMock", package: "Tool"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift")
            ],
            resources: [
                .copy("Fixtures/wallet-data.json")
            ]
        )
    ]
)
