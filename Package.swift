// swift-tools-version:5.6

/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2024 Hedera Hashgraph, LLC
 * ​
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ‍
 */

import PackageDescription

let exampleTargets = [
    "AccountAlias",
    "AccountAllowance",
    "AddNftAllowance",
    "ConsensusPubSub",
    "ConsensusPubSubChunked",
    "ConsensusPubSubWithSubmitKey",
    "CreateAccount",
    "CreateAccountThresholdKey",
    "CreateFile",
    "CreateSimpleContract",
    "CreateStatefulContract",
    "CreateTopic",
    "DeleteAccount",
    "DeleteFile",
    "FileAppendChunked",
    "GenerateKey",
    "GenerateKeyWithMnemonic",
    "GetAccountBalance",
    "GetAccountInfo",
    "GetAddressBook",
    "GetExchangeRates",
    "GetFileContents",
    "ModifyTokenKeys",
    "MultiAppTransfer",
    "MultiSigOffline",
    "Prng",
    "Schedule",
    "ScheduledTransactionMultiSigThreshold",
    "ScheduledTransfer",
    "ScheduleIdenticalTransaction",
    "ScheduleMultiSigTransaction",
    "Staking",
    "StakingWithUpdate",
    "TopicWithAdminKey",
    "TransferCrypto",
    "TransferTokens",
    "UpdateAccountPublicKey",
    "ValidateChecksum",
    "TokenUpdateMetadata",
    "NftUpdateMetadata",
    "TokenAirdrop",
].map { name in
    Target.executableTarget(
        name: "\(name)Example",
        dependencies: [
            "Hedera",
            "HederaExampleUtilities",
            .product(name: "SwiftDotenv", package: "swift-dotenv"),
        ],
        path: "Examples/\(name)",
        swiftSettings: [.unsafeFlags(["-parse-as-library"])]
    )
}

let package = Package(
    name: "Hedera",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(name: "Hedera", targets: ["Hedera"])
    ],
    dependencies: [
        .package(url: "https://github.com/objecthub/swift-numberkit.git", from: "2.5.1"),
        .package(url: "https://github.com/thebarndog/swift-dotenv.git", from: "1.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.23.0"),
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.26.0"),
        .package(url: "https://github.com/vsanthanam/AnyAsyncSequence.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.1.0"),
        // swift-asn1 wants swift 5.7+ past 0.4
        .package(url: "https://github.com/apple/swift-asn1.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", .upToNextMinor(from: "0.12.0")),
        // we use this entirely for sha3-keccak256, yes, I'm serious.
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.101.3"),
    ],
    targets: [
        .target(
            name: "HederaProtobufs",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "GRPC", package: "grpc-swift"),
            ]
        ),
        // weird name, but whatever, internal targets
        .target(
            name: "HederaExampleUtilities",
            resources: [.process("Resources")]
        ),
        .target(
            name: "Hedera",
            dependencies: [
                "HederaProtobufs",
                "AnyAsyncSequence",
                .product(name: "SwiftASN1", package: "swift-asn1"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "NumberKit", package: "swift-numberkit"),
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "secp256k1", package: "secp256k1.swift"),
                "CryptoSwift",
            ]
            // todo: find some way to enable these locally.
            // swiftSettings: [
            //     .unsafeFlags(["-Xfrontend", "-warn-concurrency", "-Xfrontend", "-enable-actor-data-race-checks"])
            // ]
        ),
        .executableTarget(
            name: "HederaTCK",
            dependencies: [
                "Hedera",
                .product(name: "Vapor", package: "vapor"),
            ]
        ),
        .testTarget(
            name: "HederaTests",
            dependencies: [
                "Hedera",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ],
            exclude: ["__Snapshots__"]
        ),
        .testTarget(
            name: "HederaE2ETests",
            dependencies: [
                "Hedera",
                .product(name: "SwiftDotenv", package: "swift-dotenv"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "HederaExampleUtilities",
            ],
            exclude: ["File/__Snapshots__"]
        ),
    ] + exampleTargets
)
