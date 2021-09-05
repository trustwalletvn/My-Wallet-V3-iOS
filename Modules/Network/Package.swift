// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Network",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
        .library(
            name: "NetworkKitMock",
            targets: ["NetworkKitMock"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(url: "git@github.com:paulo-bc/RxCombine.git", from: "1.6.2"),
        .package(url: "git@github.com:ReactiveX/RxSwift.git", from: "5.1.3"),
        .package(name: "Analytics", path: "../Analytics"),
        .package(name: "Test", path: "../Test"),
        .package(name: "Tool", path: "../Tool")
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "ToolKit", package: "Tool"),
                .product(name: "RxCombine", package: "RxCombine"),
                .product(name: "DIKit", package: "DIKit")
            ]
        ),
        .target(
            name: "NetworkKitMock",
            dependencies: [
                "NetworkKit",
                .product(name: "TestKit", package: "Test")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                "NetworkKit",
                .product(name: "RxSwift", package: "RxSwift")
            ]
        )
    ]
)
