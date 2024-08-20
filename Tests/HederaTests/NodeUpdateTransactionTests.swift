/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2023 - 2024 Hedera Hashgraph, LLC
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

import HederaProtobufs
import SnapshotTesting
import SwiftProtobuf
import XCTest

@testable import Hedera

internal final class NodeUpdateTransactionTests: XCTestCase {
    internal static let testDescription = "test description"
    internal static let testGossipCertificate = Data([0x01, 0x02, 0x03, 0x04])
    internal static let testGrpcCertificateHash = Data([0x05, 0x06, 0x07, 0x08])

    private static func makeIpv4AddressList() throws -> [SocketAddressV4] {
        [SocketAddressV4("127.0.0.1:50222")!, SocketAddressV4("127.0.0.1:50212")!]
    }

    private static func makeTransaction() throws -> NodeUpdateTransaction {
        try NodeUpdateTransaction()
            .nodeId(1)
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(
                TransactionId(
                    accountId: 5005, validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false)
            )
            .accountId(AccountId.fromString("0.0.5007"))
            .description(testDescription)
            .gossipEndpoints(try Self.makeIpv4AddressList())
            .serviceEndpoints(try Self.makeIpv4AddressList())
            .gossipCaCertificate(Self.testGossipCertificate)
            .grpcCertificateHash(Self.testGrpcCertificateHash)
            .adminKey(Key.single(Resources.privateKey.publicKey))
            .freeze()
            .sign(Resources.privateKey)
    }

    internal func testSerialize() throws {
        let tx = try Self.makeTransaction().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytes() throws {
        let tx = try Self.makeTransaction()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testFromProtoBody() throws {
        let protoData = try Com_Hedera_Hapi_Node_Addressbook_NodeUpdateTransactionBody.with { proto in
            proto.accountID = Resources.accountId.toProtobuf()
            proto.description_p = Google_Protobuf_StringValue(Self.testDescription)
            proto.gossipEndpoint = try Self.makeIpv4AddressList().map { $0.toProtobuf() }
            proto.serviceEndpoint = try Self.makeIpv4AddressList().map { $0.toProtobuf() }
            proto.gossipCaCertificate = Google_Protobuf_BytesValue(Self.testGossipCertificate)
            proto.grpcCertificateHash = Google_Protobuf_BytesValue(Self.testGrpcCertificateHash)
            proto.adminKey = Key.single(Resources.publicKey).toProtobuf()
        }

        let endpoints = try Self.makeIpv4AddressList()

        let protoBody = Proto_TransactionBody.with { proto in
            proto.nodeUpdate = protoData
            proto.transactionID = Resources.txId.toProtobuf()
        }

        let tx = try NodeUpdateTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.nodeId, 1)
        XCTAssertEqual(tx.accountId, Resources.accountId)
        XCTAssertEqual(tx.adminKey, Key.single(Resources.publicKey))
        XCTAssertEqual(tx.description, Self.testDescription)
        XCTAssertEqual(tx.gossipCaCertificate, Self.testGossipCertificate)
        XCTAssertEqual(tx.grpcCertificateHash, Self.testGrpcCertificateHash)
        XCTAssertEqual(tx.gossipEndpoints.count, 2)
        XCTAssertEqual(tx.serviceEndpoints.count, 2)

        for (index, endpoint) in tx.gossipEndpoints.enumerated() {
            XCTAssertEqual(endpoint.ip, endpoints[index].ip)
            XCTAssertEqual(endpoint.port, endpoints[index].port)
            XCTAssertEqual(endpoint.domainName, endpoints[index].domainName)
        }

        for (index, endpoint) in tx.serviceEndpoints.enumerated() {
            XCTAssertEqual(endpoint.ip, endpoints[index].ip)
            XCTAssertEqual(endpoint.port, endpoints[index].port)
            XCTAssertEqual(endpoint.domainName, endpoints[index].domainName)
        }
    }

    internal func testGetSetNodeId() throws {
        let tx = NodeUpdateTransaction()
        tx.nodeId(1)

        XCTAssertEqual(tx.nodeId, 1)
    }

    internal func testGetSetAccountId() throws {
        let tx = NodeUpdateTransaction()
        tx.accountId(Resources.accountId)

        XCTAssertEqual(tx.accountId, Resources.accountId)
    }

    internal func testGetSetAdminKey() throws {
        let tx = NodeUpdateTransaction()
        tx.adminKey(.single(Resources.publicKey))

        XCTAssertEqual(tx.adminKey, .single(Resources.publicKey))
    }

    internal func testGetSetDescription() throws {
        let tx = NodeUpdateTransaction()
        tx.description(Self.testDescription)

        XCTAssertEqual(tx.description, Self.testDescription)
    }

    internal func testGetSetGossipEndpoints() throws {
        let tx = NodeUpdateTransaction()
        let endpoints = try Self.makeIpv4AddressList()
        tx.gossipEndpoints(endpoints)

        for (index, endpoint) in tx.gossipEndpoints.enumerated() {
            XCTAssertEqual(endpoint.ip, endpoints[index].ip)
            XCTAssertEqual(endpoint.port, endpoints[index].port)
            XCTAssertEqual(endpoint.domainName, endpoints[index].domainName)
        }
    }

    internal func testGetSetServiceEndpoints() throws {
        let tx = NodeUpdateTransaction()
        let endpoints = try Self.makeIpv4AddressList()
        tx.serviceEndpoints(endpoints)

        for (index, endpoint) in tx.serviceEndpoints.enumerated() {
            XCTAssertEqual(endpoint.ip, endpoints[index].ip)
            XCTAssertEqual(endpoint.port, endpoints[index].port)
            XCTAssertEqual(endpoint.domainName, endpoints[index].domainName)
        }
    }

    internal func testGetSetGossipCaCertificate() throws {
        let tx = NodeUpdateTransaction()
        tx.gossipCaCertificate(Self.testGossipCertificate)

        XCTAssertEqual(tx.gossipCaCertificate, Self.testGossipCertificate)
    }

    internal func testGetSetGrpcCertificateHash() throws {
        let tx = NodeUpdateTransaction()
        tx.grpcCertificateHash(Self.testGrpcCertificateHash)

        XCTAssertEqual(tx.grpcCertificateHash, Self.testGrpcCertificateHash)
    }
}
