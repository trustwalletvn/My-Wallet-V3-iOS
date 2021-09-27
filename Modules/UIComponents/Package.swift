// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponentsKit"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "UIComponentsKit",
            path: "UIComponentsKit",
            resources: [.process("Fonts")]
        ),
        .testTarget(
            name: "UIComponentsKitTests",
            dependencies: ["UIComponentsKit"],
            path: "UIComponentsKitTests"
        )
    ]
)
