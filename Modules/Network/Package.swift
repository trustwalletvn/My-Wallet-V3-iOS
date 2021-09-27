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
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "RxCombine",
            url: "https://github.com/paulo-bc/RxCombine.git",
            from: "1.6.2"
        ),
        .package(
            name: "RxSwift",
            url: "https://github.com/ReactiveX/RxSwift.git",
            from: "5.1.3"
        ),
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
                .target(name: "NetworkKit"),
                .product(name: "AnalyticsKit", package: "Analytics"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "RxCombine", package: "RxCombine"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "TestKit", package: "Test"),
                .product(name: "ToolKit", package: "Tool")
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: [
                .target(name: "NetworkKit"),
                .product(name: "RxSwift", package: "RxSwift")
            ]
        )
    ]
)
