// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Localization",
    products: [
        .library(name: "Localization", targets: ["Localization"])
    ],
    targets: [
        .target(name: "Localization")
    ]
)
