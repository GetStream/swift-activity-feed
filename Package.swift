// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stream-Feed-UIKit-IOS",
    defaultLocalization: "en", // Set the default localization here
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Stream-Feed-UIKit-IOS",
            targets: ["Stream-Feed-UIKit-IOS"])
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "8.1.0")),
        .package(url: "https://github.com/AliSoftware/Reusable.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.0.0")),
        .package(path: "./stream-swift-master"),
    ],
    targets: [
        .target(
            name: "Stream-Feed-UIKit-IOS",
            dependencies: ["Nuke", "Reusable", "SnapKit",
                           .product(name: "GetStream", package: "stream-swift-master")],
            path: "Sources/"
        ),
        .testTarget(
            name: "Stream-Feed-UIKit-IOSTests",
            dependencies: ["Stream-Feed-UIKit-IOS"])
    ]
)
