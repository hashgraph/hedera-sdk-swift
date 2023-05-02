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

import AnyAsyncSequence
import Foundation
import GRPC
import HederaProtobufs

/// Query for an address book and return its nodes. The nodes are returned in ascending order by node ID.
public final class NodeAddressBookQuery: ValidateChecksums, MirrorQuery {
    public typealias Item = NodeAddress
    public typealias Response = NodeAddressBook

    /// The file ID of the address book file on the network.
    public var fileId: FileId

    /// The configured limit of node addresses to receive.
    public var limit: UInt32

    public init(_ fileId: FileId = FileId.addressBook, _ limit: UInt32 = 0) {
        self.fileId = fileId
        self.limit = limit
    }

    /// Sets the file ID of the address book file on the network.
    public func fileId(_ fileId: FileId) -> Self {
        self.fileId = fileId
        return self
    }

    /// Sets the configured limit of node addresses to receive.
    public func limit(_ limit: UInt32) -> Self {
        self.limit = limit
        return self
    }

    /// Subscribe to this query with the provided Client.
    ///
    /// - Parameters:
    ///   - client: A Hedera Client.
    ///   - timeout: an optional connection timeout.
    public func subscribe(_ client: Client, _ timeout: TimeInterval? = nil) -> AnyAsyncSequence<NodeAddress> {
        subscribeInner(client, timeout)
    }

    /// Execute this query with the provided Client.
    ///
    /// - Parameters:
    ///   - client: A Hedera Client.
    ///   - timeout: an optional connection timeout.
    public func execute(_ client: Client, _ timeout: TimeInterval? = nil) async throws -> NodeAddressBook {
        try await executeInner(client, timeout)
    }

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try fileId.validateChecksums(on: ledgerId)
    }
}

extension NodeAddressBookQuery: ToProtobuf {
    internal typealias Protobuf = Com_Hedera_Mirror_Api_Proto_AddressBookQuery

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.fileID = fileId.toProtobuf()
            proto.limit = Int32(limit)
        }
    }
}

extension NodeAddressBookQuery: MirrorRequest {
    internal typealias GrpcItem = NodeAddress.Protobuf

    internal struct Context: MirrorRequestContext {
        internal mutating func update(item: GrpcItem) {
            // do nothing
        }
    }

    internal func connect(context: Context, channel: GRPCChannel) -> GRPCAsyncResponseStream<GrpcItem> {
        let request = self.toProtobuf()

        return HederaProtobufs.Com_Hedera_Mirror_Api_Proto_NetworkServiceAsyncClient(channel: channel).getNodes(request)
    }

    internal static func collect<S>(_ stream: S) async throws -> Response
    where S: AsyncSequence, GrpcItem == S.Element {
        var items: [Item] = []
        for try await proto in stream {
            items.append(try Item.fromProtobuf(proto))
        }

        return Response(nodeAddresses: items)
    }

    internal static func makeItemStream<S>(_ stream: S) -> ItemStream
    where S: AsyncSequence, NodeAddress.Protobuf == S.Element {
        stream.map(Item.fromProtobuf).eraseToAnyAsyncSequence()
    }
}
