// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "HDWallet",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "HDWalletKit", targets: ["HDWalletKit"])
    ],
    dependencies: [
        .package(path: "../CommonCrypto"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "HDWalletKit",
            dependencies: [
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "HDWalletKitTests",
            dependencies: ["HDWalletKit"]
        )
    ]
)
