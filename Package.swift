// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetStreamActivityFeed",
    defaultLocalization: "en", // Set the default localization here
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "GetStreamActivityFeed",
            targets: ["GetStreamActivityFeed"])
    ],
    dependencies: [
        .package(url: "https://github.com/camelan/stream-swift", .upToNextMajor(from: "1.0.3")),
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "12.1.0")),
        .package(url: "https://github.com/AliSoftware/Reusable.git", .upToNextMajor(from: "4.1.2")),
        .package(url: "https://github.com/SnapKit/SnapKit", .upToNextMajor(from: "5.6.0")),
    ],
    targets: [
          .target(
              name: "GetStreamActivityFeed",
              dependencies: ["Nuke", "Reusable", "SnapKit",
                .product(name: "GetStream", package: "stream-swift") ],
              path: "Sources/"),
      ]
)
