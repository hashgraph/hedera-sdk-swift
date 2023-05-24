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

internal final class Network: Sendable {
    private init(
        map: [AccountId: Int],
        nodes: [AccountId],
        channels: [GRPCChannel],
        healthy: [ManagedAtomic<Int64>],
        lastPinged: [ManagedAtomic<Int64>]
    ) {
        self.map = map
        self.nodes = nodes
        self.channels = channels
        self.healthy = healthy
        self.lastPinged = lastPinged
    }

    internal let map: [AccountId: Int]
    internal let nodes: [AccountId]
    fileprivate let channels: [GRPCChannel]
    fileprivate let healthy: [ManagedAtomic<Int64>]
    fileprivate let lastPinged: [ManagedAtomic<Int64>]

    fileprivate convenience init(config: Config, eventLoop: NIOCore.EventLoopGroup) {
        // todo: someone verify this code pls.
        let channels = config.addresses.map { addresses in
            ChannelBalancer(eventLoop: eventLoop.next(), addresses.map { .hostAndPort($0, 50211) })
        }

        // note: `Array(repeating: <element>, count: Int)` does *not* work the way you'd want with reference types.
        let healthy = (0..<config.nodes.count).map { _ in ManagedAtomic(Int64(0)) }
        let lastPinged = (0..<config.nodes.count).map { _ in ManagedAtomic(Int64(0)) }

        self.init(
            map: config.map,
            nodes: config.nodes,
            channels: channels,
            healthy: healthy,
            lastPinged: lastPinged
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
        let channel = channels[nodeIndex]

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

        return (0..<healthy.count).filter { isNodeHealthy($0, now) }
    }

    internal func healthyNodeIds() -> [AccountId] {
        healthyNodeIndexes().map { nodes[$0] }
    }

    internal func markNodeUsed(_ index: Int, now: Timestamp) {
        lastPinged[index].store(Int64(now.unixTimestampNanos), ordering: .relaxed)
    }

    internal func nodeRecentlyPinged(_ index: Int, now: Timestamp) -> Bool {
        lastPinged[index].load(ordering: .relaxed) > Int64((now - .minutes(15)).unixTimestampNanos)
    }

    internal func isNodeHealthy(_ index: Int, _ now: Timestamp) -> Bool {
        healthy[index].load(ordering: .relaxed) < Int64(now.unixTimestampNanos)
    }
}
