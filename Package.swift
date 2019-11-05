// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hedera",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(name: "Hedera", targets: ["Hedera"]),
        
        // Examples
        .executable(name: "CreateAccountExample", targets: ["CreateAccountExample"]),
        .executable(name: "GetFileInfoExample", targets: ["GetFileInfoExample"]),
        .executable(name: "CreateFileExample", targets: ["CreateFileExample"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jedisct1/swift-sodium", .exact("0.8.0")),
        .package(url: "https://github.com/apple/swift-protobuf", .exact("1.6.0")),
        .package(url: "https://github.com/grpc/grpc-swift", .exact("0.9.1")),
    ],
    targets: [
        .target(
            name: "Hedera",
            dependencies: ["Sodium", "SwiftProtobuf", "SwiftGRPC"]),
        .testTarget(
            name: "HederaTests",
            dependencies: ["Hedera"]),
        
        // Examples
        .target(
            name: "CreateAccountExample",
            dependencies: ["Hedera"],
            path: "Examples/CreateAccount"),
        .target(
            name: "GetFileInfoExample",
            dependencies: ["Hedera"],
            path: "Examples/GetFileInfo"),
        .target(
            name: "CreateFileExample",
            dependencies: ["Hedera"],
            path: "Examples/CreateFile"),
        .target(
            name: "TransferCryptoExample",
            dependencies: ["Hedera"],
            path: "Examples/TransferCrypto"),
    ]
)
