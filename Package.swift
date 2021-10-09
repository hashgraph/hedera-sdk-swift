// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HederaSdk",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "HederaSdk", targets: ["HederaSdk"]),
        .executable(name: "GetAccountBalanceExample", targets: ["GetAccountBalanceExample"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "HederaCrypto", url: "git@github.com:launchbadge/hedera-crypto-swift.git", .branch("main")),
        .package(name: "HederaProto", url: "git@github.com:hashgraph/hedera-protobufs-swift.git", .branch("main")),
        .package(url: "https://github.com/grpc/grpc-swift", .exact("1.4.1")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", .upToNextMajor(from: "1.4.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HederaSdk",
            dependencies: [
              .product(name: "HederaProtoServices", package: "HederaProto"),
//              .product(name: "HederaProtoSdk", package: "HederaProto"),
              "HederaCrypto",
              .product(name: "GRPC", package: "grpc-swift")
            ]),
        .testTarget(name: "HederaSdkTests", dependencies: ["HederaSdk"]),
        .target(
                name: "GetAccountBalanceExample",
                dependencies: ["HederaSdk"],
                path: "Examples/GetAccountBalance"),
    ]
)
