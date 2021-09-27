// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureDashboard",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "FeatureDashboard", targets: ["FeatureDashboardUI"]),
        .library(name: "FeatureDashboardUI", targets: ["FeatureDashboardUI"])
    ],
    dependencies: [
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
        .package(path: "../FeatureTransaction"),
        .package(path: "../Network"),
        .package(path: "../Platform"),
        .package(path: "../Tool")
    ],
    targets: [
        .target(
            name: "FeatureDashboardUI",
            dependencies: [
                .product(name: "FeatureTransactionUI", package: "FeatureTransaction"),
                .product(name: "NetworkKit", package: "Network"),
                .product(name: "PlatformKit", package: "Platform"),
                .product(name: "PlatformUIKit", package: "Platform"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxDataSources", package: "RxDataSources"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureDashboardUITests",
            dependencies: [
                .target(name: "FeatureDashboardUI")
            ]
        )
    ]
)
