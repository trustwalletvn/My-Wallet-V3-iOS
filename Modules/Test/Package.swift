// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Test",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "TestKit",
            targets: ["TestKit"]
        )
    ],
    dependencies: [
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.9.0")
    ],
    targets: [
        .target(
            name: "TestKit",
            dependencies: [
                .product(name: "SnapshotTesting", package: "SnapshotTesting")
            ]
        )
    ]
)
