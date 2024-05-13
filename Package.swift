// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Punchcard",
    platforms: [ .macOS(.v14) ],
    products: [
        .executable(name: "pcard", targets: ["pcard"]),
        .library(name: "Punchcard", targets: ["Punchcard"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "pcard",
            dependencies: ["Punchcard"]
        ),
        .target(
            name: "Punchcard",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
