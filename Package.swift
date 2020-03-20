// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetStreamActivityFeed",
    products: [
        .library(
            name: "GetStreamActivityFeed",
            targets: ["GetStreamActivityFeed"]),
    ],
    dependencies: [
        .package(url: "https://github.com/GetStream/stream-swift", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "8.1.0")),
        .package(url: "https://github.com/AliSoftware/Reusable.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "GetStreamActivityFeed",
            dependencies: ["GetStream", "Nuke", "Reusable", "SnapKit"]),
    ]
)
