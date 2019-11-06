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
        .executable(name: "SimpleCreateAccountExample", targets: ["SimpleCreateAccountExample"]),
        .executable(name: "AdvancedCreateAccountExample", targets: ["AdvancedCreateAccountExample"]),
        .executable(name: "GetFileInfoExample", targets: ["GetFileInfoExample"]),
        .executable(name: "CreateFileExample", targets: ["CreateFileExample"]),
        .executable(name: "SimpleTransferCryptoExample", targets: ["SimpleTransferCryptoExample"]),
        .executable(name: "AdvancedTransferCryptoExample", targets: ["AdvancedTransferCryptoExample"]),
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
            name: "SimpleCreateAccountExample",
            dependencies: ["Hedera"],
            path: "Examples/SimpleCreateAccount"),
        .target(
            name: "AdvancedCreateAccountExample",
            dependencies: ["Hedera"],
            path: "Examples/AdvancedCreateAccount"),
        .target(
            name: "GetFileInfoExample",
            dependencies: ["Hedera"],
            path: "Examples/GetFileInfo"),
        .target(
            name: "CreateFileExample",
            dependencies: ["Hedera"],
            path: "Examples/CreateFile"),
        .target(
            name: "SimpleTransferCryptoExample",
            dependencies: ["Hedera"],
            path: "Examples/SimpleTransferCrypto"),
        .target(
            name: "AdvancedTransferCryptoExample",
            dependencies: ["Hedera"],
            path: "Examples/AdvancedTransferCrypto"),
    ]
)
