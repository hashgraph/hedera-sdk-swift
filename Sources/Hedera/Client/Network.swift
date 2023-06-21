/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2023 - 2023 Hedera Hashgraph, LLC
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

import Atomics
import Foundation
import GRPC
import NIOCore
import SwiftProtobuf

// Note: Ideally this would use some form of algorithm to balance better (IE P2C, but how do you check connection metrics?)
// Random is surprisingly good at this though (avoids the thundering herd that would happen if round-robin was used), so...
internal final class ChannelBalancer: GRPCChannel {
    internal let eventLoop: EventLoop
    private let channels: [any GRPCChannel]
    private let targets: [GRPC.ConnectionTarget]

    // fixme: if the request never returns (IE the host doesn't exist) we

    internal init(eventLoop: EventLoop, _ channelTargets: [GRPC.ConnectionTarget]) {
        self.eventLoop = eventLoop
        self.targets = channelTargets

        self.channels = channelTargets.map { target in
            // GRPC.ClientConnection(configuration: .default(target: target, eventLoopGroup: eventLoop))
            try! GRPCChannelPool.with(target: target, transportSecurity: .plaintext, eventLoopGroup: eventLoop)
        }
    }

    internal func makeCall<Request, Response>(
        path: String,
        type: GRPC.GRPCCallType,
        callOptions: GRPC.CallOptions,
        interceptors: [GRPC.ClientInterceptor<Request, Response>]
    )
        -> GRPC.Call<Request, Response> where Request: GRPC.GRPCPayload, Response: GRPC.GRPCPayload
    {
        let elem = channels.randomElement()!

        let res = elem.makeCall(path: path, type: type, callOptions: callOptions, interceptors: interceptors)

        return res
    }

    internal func makeCall<Request, Response>(
        path: String,
        type: GRPC.GRPCCallType,
        callOptions: GRPC.CallOptions,
        interceptors: [GRPC.ClientInterceptor<Request, Response>]
    ) -> GRPC.Call<Request, Response> where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        let elem = channels.randomElement()!

        let res = elem.makeCall(path: path, type: type, callOptions: callOptions, interceptors: interceptors)

        return res
    }

    // todo: have someone look at this.
    internal func close() -> NIOCore.EventLoopFuture<Void> {
        return EventLoopFuture.reduce(into: (), channels.map { $0.close() }, on: eventLoop, { (_, _) in })
    }
}

internal final class Network: Sendable, AtomicReference {
    private init(
        map: [AccountId: Int],
        nodes: [AccountId],
        health: [NodeHealth],
        connections: [NodeConnection]
    ) {
        self.map = map
        self.nodes = nodes
        self.health = health
        self.connections = connections
    }

    internal let map: [AccountId: Int]
    internal let nodes: [AccountId]
    fileprivate let health: [NodeHealth]
    fileprivate let connections: [NodeConnection]

    internal var addresses: [String: AccountId] {
        Dictionary(
            map.lazy.flatMap { (account, index) in
                self.connections[index].addresses.lazy.map { (String(describing: $0), account) }
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    fileprivate convenience init(config: Config, eventLoop: NIOCore.EventLoopGroup) {
        // todo: someone verify this code pls.
        let connections = config.addresses.map { addresses in
            let addresses = Set(addresses.map { HostAndPort(host: $0, port: 50211) })
            return NodeConnection(eventLoop: eventLoop.next(), addresses: addresses)
        }

        // note: `Array(repeating: <element>, count: Int)` does *not* work the way you'd want with reference types.
        let health = (0..<config.nodes.count).map { _ in NodeHealth() }

        self.init(
            map: config.map,
            nodes: config.nodes,
            health: health,
            connections: connections
        )
    }

    internal convenience init(addresses: [String: AccountId], eventLoop: EventLoop) throws {
        let tmp = try Self.withAddresses(
            Self(map: [:], nodes: [], health: [], connections: []), addresses, eventLoop: eventLoop)
        self.init(map: tmp.map, nodes: tmp.nodes, health: tmp.health, connections: tmp.connections)
    }

    internal static func withAddressBook(_ old: Network, _ eventLoop: EventLoop, _ addressBook: NodeAddressBook) -> Self
    {
        let addressBook = addressBook.nodeAddresses

        var map: [AccountId: Int] = [:]
        var nodeIds: [AccountId] = []
        var health: [NodeHealth] = []
        var connections: [NodeConnection] = []

        for (index, address) in addressBook.enumerated() {
            let new = Set(
                address.serviceEndpoints.compactMap {
                    $0.port == NodeConnection.plaintextPort
                        ? HostAndPort(host: String(describing: $0.ip), port: NodeConnection.plaintextPort) : nil
                })

            // if the node is the exact same we want to reuse everything (namely the connections and `healthy`).
            // if the node has different routes then we still want to reuse `healthy` but replace the channel with a new channel.
            // if the node just flat out doesn't exist in `old`, we want to add the new node.
            // and, last but not least, if the node doesn't exist in `new` we want to get rid of it.

            let upsert: (NodeHealth, NodeConnection)

            switch old.map[address.nodeAccountId] {
            case .some(let account):
                let connection: NodeConnection
                switch old.connections[account].addresses.symmetricDifference(new).count {
                case 0: connection = old.connections[account]
                case _: connection = NodeConnection(eventLoop: eventLoop, addresses: new)
                }

                upsert = (old.health[account], connection)
            case nil: upsert = (NodeHealth(), NodeConnection(eventLoop: eventLoop, addresses: new))
            }

            map[address.nodeAccountId] = index
            nodeIds.append(address.nodeAccountId)
            health.append(upsert.0)
            connections.append(upsert.1)
        }

        return Self(
            map: map,
            nodes: nodeIds,
            health: health,
            connections: connections
        )
    }

    internal static func withAddresses(_ old: Network, _ addresses: [String: AccountId], eventLoop: EventLoop) throws
        -> Self
    {
        var map: [AccountId: Int] = [:]
        var nodeIds: [AccountId] = []
        var health: [NodeHealth] = []
        var connections: [NodeConnection] = []

        let addresses = Dictionary(
            try addresses.map { (key, value) throws -> (AccountId, Set<HostAndPort>) in
                let res = Set([try HostAndPort(parsing: key)])
                return (value, res)
            },
            uniquingKeysWith: { $0.union($1) }
        )

        for (node, addresses) in addresses {
            let nextIndex = nodeIds.count

            map[node] = nextIndex
            nodeIds.append(node)

            var reusedHealth: NodeHealth?
            var reusedConnection: NodeConnection?

            if let index = old.map[node] {
                if old.connections[index].addresses.symmetricDifference(addresses).count == 0 {
                    reusedConnection = old.connections[index]
                }

                reusedHealth = old.health[index]
            }

            health.append(reusedHealth ?? .init())
            connections.append(reusedConnection ?? .init(eventLoop: eventLoop, addresses: addresses))
        }

        return Self(
            map: map,
            nodes: nodeIds,
            health: health,
            connections: connections
        )
    }

    internal static func mainnet(_ eventLoop: NIOCore.EventLoopGroup) -> Self {
        Self(config: Config.mainnet, eventLoop: eventLoop)
    }

    internal static func testnet(_ eventLoop: NIOCore.EventLoopGroup) -> Self {
        Self(config: Config.testnet, eventLoop: eventLoop)
    }

    internal static func previewnet(_ eventLoop: NIOCore.EventLoopGroup) -> Self {
        Self(config: Config.previewnet, eventLoop: eventLoop)
    }

    internal func channel(for nodeIndex: Int) -> (AccountId, GRPCChannel) {
        let accountId = nodes[nodeIndex]
        let channel = connections[nodeIndex].channel

        return (accountId, channel)
    }

    internal func nodeIndexesForIds(_ nodeAccountIds: [AccountId]) throws -> [Int] {
        try nodeAccountIds.map { id in
            guard let index = map[id] else {
                throw HError(kind: .nodeAccountUnknown, description: "Node account \(id) is unknown")
            }

            return index
        }
    }

    internal func healthyNodeIndexes() -> [Int] {
        let now = Timestamp.now

        return (0..<health.count).filter { isNodeHealthy($0, now) }
    }

    internal func healthyNodeIds() -> [AccountId] {
        healthyNodeIndexes().map { nodes[$0] }
    }

    internal func markNodeUsed(_ index: Int, now: Timestamp) {
        health[index].lastPinged.store(Int64(now.unixTimestampNanos), ordering: .relaxed)
    }

    internal func nodeRecentlyPinged(_ index: Int, now: Timestamp) -> Bool {
        health[index].lastPinged.load(ordering: .relaxed) > Int64((now - .minutes(15)).unixTimestampNanos)
    }

    internal func isNodeHealthy(_ index: Int, _ now: Timestamp) -> Bool {
        health[index].health.load(ordering: .relaxed) < Int64(now.unixTimestampNanos)
    }

    internal func randomNodeIds()
        -> [AccountId]
    {
        var nodeIds = self.healthyNodeIds()

        if nodeIds.isEmpty {
            nodeIds = self.nodes
        }

        let nodeSampleAmount = (nodeIds.count + 2) / 3

        let nodeIdIndecies = randomIndexes(upTo: nodeIds.count, amount: nodeSampleAmount)
        return nodeIdIndecies.map { nodeIds[$0] }
    }
}

// this needs to be a class for reference semantics.
internal final class NodeHealth: Sendable {
    internal let health: ManagedAtomic<Int64>
    internal let lastPinged: ManagedAtomic<Int64>
    internal init() {
        self.health = .init(0)
        self.lastPinged = .init(0)
    }
}

internal struct HostAndPort: Hashable, Equatable {
    internal let host: String
    internal let port: UInt16
}

extension HostAndPort: LosslessStringConvertible {
    internal init?<S: StringProtocol>(_ description: S) {
        let (host, port) = description.splitOnce(on: ":") ?? (description[...], nil)

        guard let port = port else {
            self = .init(host: String(host), port: 443)
            return
        }

        guard let port = UInt16(port) else {
            return nil
        }

        self = .init(host: String(host), port: port)
    }

    internal init<S: StringProtocol>(parsing description: S) throws {
        guard let tmp = Self(description) else {
            throw HError.basicParse("invalid URL")
        }

        self = tmp
    }

    internal var description: String {
        "\(host):\(port)"
    }

}

internal struct NodeConnection: Sendable {
    internal init(eventLoop: EventLoop, addresses: Set<HostAndPort>) {
        realChannel = ChannelBalancer(eventLoop: eventLoop, addresses.map { .host($0.host, port: Int($0.port)) })
        self.addresses = addresses
    }

    internal let addresses: Set<HostAndPort>
    private let realChannel: ChannelBalancer

    internal var channel: any GRPCChannel {
        realChannel
    }

    internal static let plaintextPort: UInt16 = 50211
}
