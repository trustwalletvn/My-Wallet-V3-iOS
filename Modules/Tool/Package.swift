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
        .package(url: "git@github.com:jackpooleybc/DIKit.git", .branch("safe-property-wrappers")),
        .package(url: "git@github.com:paulo-bc/RxCombine.git", from: "1.6.2"),
        .package(url: "git@github.com:ReactiveX/RxSwift.git", from: "5.1.3"),
        .package(url: "git@github.com:attaswift/BigInt.git", from: "5.2.1")
    ],
    targets: [
        .target(
            name: "ToolKit",
            dependencies: [
                "RxSwift",
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxCombine", package: "RxCombine"),
                .product(name: "DIKit", package: "DIKit"),
                .product(name: "BigInt", package: "BigInt")
            ]
        ),
        .target(
            name: "ToolKitMock",
            dependencies: [
                "ToolKit"
            ]
        ),
        .testTarget(
            name: "ToolKitTests",
            dependencies: [
                "ToolKit",
                "RxSwift",
                .product(name: "RxRelay", package: "RxSwift"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                .product(name: "DIKit", package: "DIKit")
            ]
        )
    ]
)
