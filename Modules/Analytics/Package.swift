// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AnalyticsKit",
            targets: ["AnalyticsKit"]
        ),
        .library(
            name: "RxAnalyticsKit",
            targets: ["RxAnalyticsKit"]
        ),
        .library(
            name: "AnalyticsKitMock",
            targets: ["AnalyticsKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "CombineExt",
            url: "https://github.com/CombineCommunity/CombineExt.git",
            from: "1.3.0"
        ),
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
        .package(
            name: "Mockingbird",
            url: "https://github.com/birdrides/mockingbird.git",
            from: "0.16.0"
        )
    ],
    targets: [
        .target(
            name: "AnalyticsKit",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt")
            ]
        ),
        .target(
            name: "RxAnalyticsKit",
            dependencies: [
                .target(name: "AnalyticsKit"),
                .product(name: "RxSwift", package: "RxSwift")
            ]
        ),
        .target(
            name: "AnalyticsKitMock",
            dependencies: [
                .target(name: "AnalyticsKit")
            ]
        ),
        .testTarget(
            name: "AnalyticsKitTests",
            dependencies: [
                .target(name: "AnalyticsKit"),
                .target(name: "RxAnalyticsKit"),
                .product(name: "Mockingbird", package: "Mockingbird")
            ]
        )
    ]
)
