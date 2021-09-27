// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureTour",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureTour",
            targets: [
                "FeatureTourData",
                "FeatureTourDomain",
                "FeatureTourUI"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.24.0"),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.9.0"),
        .package(path: "../UIComponents")
    ],
    targets: [
        .target(
            name: "FeatureTourData",
            dependencies: [
                "FeatureTourDomain"
            ],
            path: "Data"
        ),
        .target(
            name: "FeatureTourDomain",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Domain"
        ),
        .target(
            name: "FeatureTourUI",
            dependencies: [
                "FeatureTourDomain",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "UI"
        ),
        .testTarget(
            name: "FeatureTourTests",
            dependencies: [
                "FeatureTourData",
                "FeatureTourDomain",
                "FeatureTourUI",
                "SnapshotTesting",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Tests"
        )
    ]
)
