// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Tool",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "ToolKit",
            targets: ["ToolKit"]
        ),
        .library(
            name: "ToolKitMock",
            targets: ["ToolKitMock"]
        )
    ],
    dependencies: [
        .package(
            name: "DIKit",
            url: "https://github.com/jackpooleybc/DIKit.git",
            .branch("safe-property-wrappers")
        ),
        .package(
            name: "CombineExt",
            url: "https://github.com/CombineCommunity/CombineExt.git",
            from: "1.3.0"
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
        .package(
            name: "BigInt",
            url: "https://github.com/attaswift/BigInt.git",
            from: "5.2.1"
        ),
        .package(path: "../Test")
    ],
    targets: [
        .target(
            name: "ToolKit",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCombine", package: "RxCombine"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "BigInt", package: "BigInt")
            ]
        ),
        .target(
            name: "ToolKitMock",
            dependencies: [
                .target(name: "ToolKit")
            ]
        ),
        .testTarget(
            name: "ToolKitTests",
            dependencies: [
                .target(name: "ToolKit"),
                .target(name: "ToolKitMock"),
                .product(name: "TestKit", package: "Test")
            ]
        )
    ]
)
