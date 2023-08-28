/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
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

import Foundation
import HederaProtobufs
import Network

public struct SocketAddressV4: LosslessStringConvertible {
    // name is is to match the other SDKs.
    // swiftlint:disable:next identifier_name
    public var ip: IPv4Address
    public var port: UInt16

    fileprivate init(ipBytes: Data, port: Int32) throws {
        guard let ipAddress = IPv4Address(ipBytes) else {
            throw HError.basicParse("expected 4 byte ip address, got `\(ipBytes.count)` bytes")
        }

        guard let port = UInt16(exactly: port) else {
            throw HError(
                kind: .basicParse,
                description: "expected 16 bit non-negative port number, but the port was actually `\(port)`")
        }

        self.ip = ipAddress
        self.port = port
    }

    fileprivate init<S: StringProtocol>(parsing description: S) throws {
        guard let (ipAddress, port) = description.splitOnce(on: ":") else {
            throw HError.basicParse("expected ip:port")
        }

        guard let ipAddress = IPv4Address(String(ipAddress)) else {
            throw HError.basicParse("expected `ip` to be a valid IP")
        }

        guard let port = UInt16(port) else {
            throw HError.basicParse("expected 16 bit port number")
        }

        self.ip = ipAddress
        self.port = port
    }

    public init?(_ description: String) {
        try? self.init(parsing: description)
    }

    public var description: String {
        "\(ip):\(port)"
    }
}

extension SocketAddressV4: TryProtobufCodable {
    internal typealias Protobuf = Proto_ServiceEndpoint

    internal init(protobuf proto: Protobuf) throws {
        try self.init(ipBytes: proto.ipAddressV4, port: proto.port)
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.ipAddressV4 = ip.rawValue
            proto.port = Int32(port)
        }
    }
}

/// The data about a node, including its service endpoints and the Hedera account to be paid for
/// services provided by the node (that is, queries answered and transactions submitted.).
public struct NodeAddress {
    /// A non-sequential, unique, static identifier for the node
    public var nodeId: UInt64

    /// The node's X509 RSA public key used to sign stream files.
    public var rsaPublicKey: Data

    /// The account to be paid for queries and transactions sent to this node.
    public var nodeAccountId: AccountId

    /// Hash of the node's TLS certificate.
    ///
    /// Precisely, this field is a string of
    /// hexadecimal characters which, translated to binary, are the SHA-384 hash of
    /// the UTF-8 NFKD encoding of the node's TLS cert in PEM format.
    ///
    /// Its value can be used to verify the node's certificate it presents during TLS negotiations.
    public var tlsCertificateHash: Data

    /// A node's service IP addresses and ports.
    public var serviceEndpoints: [SocketAddressV4]

    /// A description of the node, up to 100 bytes.
    public var description: String
}

extension NodeAddress: TryProtobufCodable {
    internal typealias Protobuf = Proto_NodeAddress

    internal init(protobuf proto: Protobuf) throws {
        var addresses: [SocketAddressV4] = []
        if !proto.ipAddress.isEmpty {
            addresses.append(try SocketAddressV4(ipBytes: proto.ipAddress, port: proto.portno))
        }

        for address in proto.serviceEndpoint {
            addresses.append(try .fromProtobuf(address))
        }

        self.init(
            nodeId: UInt64(proto.nodeID),
            rsaPublicKey: Data(hexEncoded: proto.rsaPubKey) ?? Data(),
            nodeAccountId: try .fromProtobuf(proto.nodeAccountID),
            tlsCertificateHash: proto.nodeCertHash,
            serviceEndpoints: addresses,
            description: proto.description_p
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.nodeID = Int64(nodeId)
            proto.rsaPubKey = rsaPublicKey.hexStringEncoded()
            proto.nodeAccountID = nodeAccountId.toProtobuf()
            proto.nodeCertHash = tlsCertificateHash
            proto.serviceEndpoint = serviceEndpoints.toProtobuf()
            proto.description_p = description
        }
    }
}
