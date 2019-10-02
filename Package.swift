// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Consolidate",
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
    ]
)
