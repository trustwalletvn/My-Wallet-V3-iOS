// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FeatureAccountPicker",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "FeatureAccountPicker",
            targets: [
                "FeatureAccountPickerData",
                "FeatureAccountPickerDomain",
                "FeatureAccountPickerUI"
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
            name: "FeatureAccountPickerData",
            dependencies: [
                "FeatureAccountPickerDomain"
            ],
            path: "Data"
        ),
        .target(
            name: "FeatureAccountPickerDomain",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Domain"
        ),
        .target(
            name: "FeatureAccountPickerUI",
            dependencies: [
                "FeatureAccountPickerDomain",
                "UIComponents",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "UI"
        ),
        .testTarget(
            name: "FeatureAccountPickerTests",
            dependencies: [
                "FeatureAccountPickerData",
                "FeatureAccountPickerDomain",
                "FeatureAccountPickerUI",
                "SnapshotTesting",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Tests"
        )
    ]
)
