// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureOnboarding",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "FeatureOnboarding", targets: ["FeatureOnboardingUI"]),
        .library(name: "FeatureOnboardingUI", targets: ["FeatureOnboardingUI"])
    ],
    dependencies: [
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(path: "../Tool"),
        .package(path: "../Test"),
        .package(path: "../Platform")
    ],
    targets: [
        .target(
            name: "FeatureOnboardingUI",
            dependencies: [
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "FeatureOnboardingUITests",
            dependencies: [
                .target(name: "FeatureOnboardingUI"),
                .product(name: "PlatformUIKitMock", package: "Platform"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKitMock", package: "Tool")
            ]
        )
    ]
)
