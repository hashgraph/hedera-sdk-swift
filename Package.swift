// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hedera",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Hedera",
            targets: ["Hedera"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jedisct1/swift-sodium", from: "0.8.0"),
        .package(url: "https://github.com/apple/swift-protobuf", from: "1.6.0"),
        .package(url: "https://github.com/grpc/grpc-swift", from: "0.9.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Hedera",
            dependencies: ["Sodium", "SwiftProtobuf", "SwiftGRPC"]),
        .testTarget(
            name: "HederaTests",
            dependencies: ["Hedera"]),
        // .target(
        //     name: "HederaExamples",
        //     dependencies: ["Hedera"],
        //     path: "Examples"),
    ]
)
