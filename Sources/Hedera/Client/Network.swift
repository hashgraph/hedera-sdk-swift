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
    private let channels: [GRPC.ClientConnection]

    internal init(eventLoop: EventLoop, _ channelTargets: [GRPC.ConnectionTarget]) {
        self.eventLoop = eventLoop

        self.channels = channelTargets.map { target in
            GRPC.ClientConnection(configuration: .default(target: target, eventLoopGroup: eventLoop))
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
        channels.randomElement()!.makeCall(path: path, type: type, callOptions: callOptions, interceptors: interceptors)
    }

    internal func makeCall<Request, Response>(
        path: String,
        type: GRPC.GRPCCallType,
        callOptions: GRPC.CallOptions,
        interceptors: [GRPC.ClientInterceptor<Request, Response>]
    ) -> GRPC.Call<Request, Response> where Request: SwiftProtobuf.Message, Response: SwiftProtobuf.Message {
        channels.randomElement()!.makeCall(path: path, type: type, callOptions: callOptions, interceptors: interceptors)
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
    let host: String
    let port: UInt16
}

internal struct NodeConnection: Sendable {
    internal init(eventLoop: EventLoop, addresses: Set<HostAndPort>) {
        realChannel = ChannelBalancer(eventLoop: eventLoop, addresses.map { .host($0.host, port: Int($0.port)) })
        self.addresses = addresses
    }

    let addresses: Set<HostAndPort>
    private let realChannel: ChannelBalancer

    internal var channel: any GRPCChannel {
        realChannel
    }
}
