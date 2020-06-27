// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Consolidate",
    platforms: [.macOS(.v10_10),
                .iOS(.v8),
                .tvOS(.v9),
                .watchOS(.v2)],
    products: [
        .library(
            name: "Consolidate",
            type: .static,
            targets: ["Consolidate"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Consolidate",
            dependencies: []),
        .testTarget(
            name: "ConsolidateTests",
            dependencies: ["Consolidate"]),
    ],
    swiftLanguageVersions: [.v5]
)
