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

import Atomics
import Foundation
import GRPC
import NIOConcurrencyHelpers
import NIOCore

/// Managed client for use on the Hedera network.
public final class Client: Sendable {
    internal let eventLoop: NIOCore.EventLoopGroup

    private let network: ManagedNetwork
    private let operatorInner: NIOLockedValueBox<Operator?>
    private let autoValidateChecksumsInner: ManagedAtomic<Bool>
    private let networkUpdateTask: NetworkUpdateTask
    private let regenerateTransactionIdInner: ManagedAtomic<Bool>
    private let maxTransactionFeeInner: ManagedAtomic<Int64>
    private let networkUpdateIntervalInner: NIOLockedValueBox<UInt64?>

    private init(
        network: ManagedNetwork,
        ledgerId: LedgerId?,
        networkUpdateInterval: UInt64? = 86400 * 1_000_000_000,
        _ eventLoop: NIOCore.EventLoopGroup
    ) {
        self.eventLoop = eventLoop
        self.network = network
        self.operatorInner = .init(nil)
        self.ledgerIdInner = .init(ledgerId)
        self.autoValidateChecksumsInner = .init(false)
        self.regenerateTransactionIdInner = .init(true)
        self.maxTransactionFeeInner = .init(0)
        self.networkUpdateTask = NetworkUpdateTask(
            eventLoop: eventLoop,
            managedNetwork: network,
            updateInterval: networkUpdateInterval
        )
        self.networkUpdateIntervalInner = .init(networkUpdateInterval)
    }

    /// Note: this operation is O(n)
    private var nodes: [AccountId] {
        network.primary.load(ordering: .relaxed).nodes
    }

    internal var mirrorChannel: GRPCChannel { network.mirror.channel }

    internal var `operator`: Operator? {
        return operatorInner.withLockedValue { $0 }
    }

    internal var maxTransactionFee: Hbar? {
        let value = maxTransactionFeeInner.load(ordering: .relaxed)

        guard value != 0 else {
            return nil
        }

        return .fromTinybars(value)
    }

    /// Construct a Hedera client pre-configured for mainnet access.
    public static func forMainnet() -> Self {
        let eventLoop = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return Self(
            network: .mainnet(eventLoop),
            ledgerId: .mainnet,
            eventLoop
        )
    }

    /// Construct a Hedera client pre-configured for testnet access.
    public static func forTestnet() -> Self {
        let eventLoop = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return Self(
            network: .testnet(eventLoop),
            ledgerId: .testnet,
            eventLoop
        )
    }

    /// Construct a Hedera client pre-configured for previewnet access.
    public static func forPreviewnet() -> Self {
        let eventLoop = PlatformSupport.makeEventLoopGroup(loopCount: 1)
        return Self(
            network: .previewnet(eventLoop),
            ledgerId: .previewnet,
            eventLoop
        )
    }

    // wish I could write `init(for name: String)`
    public static func forName(_ name: String) throws -> Self {
        switch name {
        case "mainnet":
            return .forMainnet()

        case "testnet":
            return .forTestnet()

        case "previewnet":
            return .forPreviewnet()

        default:
            throw HError(kind: .basicParse, description: "Unknown network name \(name)")
        }
    }

    /// Sets the account that will, by default, be paying for transactions and queries built with
    /// this client.
    @discardableResult
    public func setOperator(_ accountId: AccountId, _ privateKey: PrivateKey) -> Self {
        operatorInner.withLockedValue { $0 = .init(accountId: accountId, signer: .privateKey(privateKey)) }

        return self
    }

    public func ping(_ nodeAccountId: AccountId) async throws {
        try await PingQuery(nodeAccountId: nodeAccountId).execute(self)
    }

    public func ping(_ nodeAccountId: AccountId, _ timeout: TimeInterval) async throws {
        try await PingQuery(nodeAccountId: nodeAccountId).execute(self, timeout: timeout)
    }

    public func pingAll() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for node in self.nodes {
                group.addTask {
                    try await self.ping(node)
                }

                try await group.waitForAll()
            }
        }
    }

    public func pingAll(_ timeout: TimeInterval) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for node in self.nodes {
                group.addTask {
                    try await self.ping(node, timeout)
                }

                try await group.waitForAll()
            }
        }
    }

    private let ledgerIdInner: NIOLockedValueBox<LedgerId?>

    @discardableResult
    public func setLedgerId(_ ledgerId: LedgerId?) -> Self {
        self.ledgerId = ledgerId

        return self
    }

    // note: matches JS
    public var ledgerId: LedgerId? {
        get {
            ledgerIdInner.withLockedValue { $0 }
        }

        set(value) {
            ledgerIdInner.withLockedValue { $0 = value }
        }
    }

    fileprivate var autoValidateChecksums: Bool {
        get { self.autoValidateChecksumsInner.load(ordering: .relaxed) }
        set(value) { self.autoValidateChecksumsInner.store(value, ordering: .relaxed) }
    }

    @discardableResult
    public func setAutoValidateChecksums(_ autoValidateChecksums: Bool) -> Self {
        self.autoValidateChecksums = autoValidateChecksums

        return self
    }

    public func isAutoValidateChecksumsEnabled() -> Bool {
        autoValidateChecksums
    }

    /// Whether or not the transaction ID should be refreshed if a ``Status/transactionExpired`` occurs.
    ///
    /// By default, this is true.
    ///
    /// >Note: Some operations forcibly disable transaction ID regeneration, such as setting the transaction ID explicitly.
    public var defaultRegenerateTransactionId: Bool {
        get { self.regenerateTransactionIdInner.load(ordering: .relaxed) }
        set(value) { self.regenerateTransactionIdInner.store(value, ordering: .relaxed) }
    }

    /// Sets whether or not the transaction ID should be refreshed if a ``Status/transactionExpired`` occurs.
    ///
    /// Various operations such as setting the transaction ID exlicitly can forcibly disable transaction ID regeneration.
    @discardableResult
    public func setDefaultRegenerateTransactionId(_ defaultRegenerateTransactionId: Bool) -> Self {
        self.defaultRegenerateTransactionId = defaultRegenerateTransactionId

        return self
    }

    internal func generateTransactionId() -> TransactionId? {
        (self.operator?.accountId).map { .generateFrom($0) }
    }

    internal var net: Network {
        network.primary.load(ordering: .relaxed)
    }

    internal var mirrorNet: MirrorNetwork {
        network.mirror
    }

    public var networkUpdateInterval: UInt64? {
        networkUpdateIntervalInner.withLockedValue { $0 }
    }

    public func setNetworkUpdateInterval(nanoseconds: UInt64?) async {
        await self.networkUpdateTask.setUpdateInterval(nanoseconds)
        self.networkUpdateIntervalInner.withLockedValue { $0 = nanoseconds }
    }
}
