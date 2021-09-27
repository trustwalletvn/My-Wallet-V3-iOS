// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Blockchain",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:CombineCommunity/CombineExt.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            dependencies: ["CombineExt"],
            path: "Modules/Analytics/Sources/AnalyticsKit"
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            dependencies: ["CombineExt"],
            path: "Modules/Analytics/Tests/AnalyticsKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
