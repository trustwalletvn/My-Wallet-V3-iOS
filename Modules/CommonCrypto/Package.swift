// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CommonCrypto",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(name: "CommonCryptoKit", targets: ["CommonCryptoKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.4.1"),
        .package(
            name: "WalletCore",
            url: "git@github.com:oliveratkinson-bc/wallet-core.git",
            .revision("44bf856ce6cea5d804c2182804e8659dc59fc82a")
        ),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "CommonCryptoKit",
            dependencies: [
                .product(name: "WalletCore", package: "WalletCore"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            linkerSettings: [
                .linkedLibrary("c++")
            ]
        ),
        .testTarget(
            name: "CommonCryptoKitTests",
            dependencies: [
                "CommonCryptoKit",
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
