// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureActivity",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "FeatureActivity", targets: ["FeatureActivityDomain", "FeatureActivityUI"]),
        .library(name: "FeatureActivityDomain", targets: ["FeatureActivityDomain"]),
        .library(name: "FeatureActivityUI", targets: ["FeatureActivityUI"])
    ],
    dependencies: [
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
        .package(path: "../CommonCrypto"),
        .package(path: "../CryptoAssets"),
        .package(path: "../FeatureAuthentication"),
        .package(path: "../FeatureKYC"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../Tool"),
        .package(path: "../WalletPayload")
    ],
    targets: [
        .target(
            name: "FeatureActivityDomain",
            dependencies: [
                .product(name: "BitcoinCashKit", package: "CryptoAssets"),
                .product(name: "BitcoinChainKit", package: "CryptoAssets"),
                .product(name: "BitcoinKit", package: "CryptoAssets"),
                .product(name: "EthereumKit", package: "CryptoAssets"),
                .product(name: "ERC20Kit", package: "CryptoAssets"),
                .product(name: "StellarKit", package: "CryptoAssets"),
                .product(name: "CommonCryptoKit", package: "CommonCrypto"),
                .product(name: "FeatureAuthenticationDomain", package: "FeatureAuthentication"),
                .product(name: "FeatureKYCDomain", package: "FeatureKYC"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "WalletPayloadKit", package: "WalletPayload")
            ]
        ),
        .target(
            name: "FeatureActivityUI",
            dependencies: [
                .target(name: "FeatureActivityDomain"),
                .product(name: "FeatureKYCUI", package: "FeatureKYC")
            ]
        ),
        .testTarget(
            name: "FeatureActivityDomainTests",
            dependencies: [
                .target(name: "FeatureActivityDomain")
            ]
        ),
        .testTarget(
            name: "FeatureActivityUITests",
            dependencies: [
                .target(name: "FeatureActivityUI")
            ]
        )
    ]
)
