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

import GRPC
import HederaProtobufs

/// Token claim airdrop
/// Complete one or more pending transfers on behalf of the
/// recipient(s) for an airdrop.
///
/// The sender MUST have sufficient balance to fulfill the airdrop at the
/// time of claim. If the sender does not have sufficient balance, the
/// claim SHALL fail.
/// Each pending airdrop successfully claimed SHALL be removed from state and
/// SHALL NOT be available to claim again.
/// Each claim SHALL be represented in the transaction body and
/// SHALL NOT be restated in the record file.
/// All claims MUST succeed for this transaction to succeed.
///
/// ### Record Stream Effects
/// The completed transfers SHALL be present in the transfer list.
///
public final class TokenClaimAirdropTransaction: Transaction {
    /// Create a new `TokenClaimAirdropTransaction`.
    public init(
        pendingAirdropIds: [PendingAirdropId] = []
    ) {
        self.pendingAirdropIds = pendingAirdropIds

        super.init()
    }

    internal init(protobuf proto: Proto_TransactionBody, _ data: Proto_TokenClaimAirdropTransactionBody) throws {
        self.pendingAirdropIds = try data.pendingAirdrops.map(PendingAirdropId.init)

        try super.init(protobuf: proto)
    }

    /// A list of one or more pending airdrop identifiers.
    public var pendingAirdropIds: [PendingAirdropId] {
        willSet {
            ensureNotFrozen()
        }
    }

    /// Set the pending airdrop ids
    @discardableResult
    public func pendingAirdropIds(_ pendingAirdropIds: [PendingAirdropId]) -> Self {
        self.pendingAirdropIds = pendingAirdropIds

        return self
    }

    /// Add a pending airdrop id
    @discardableResult
    public func addPendingAirdropId(_ pendingAirdropId: PendingAirdropId) -> Self {
        self.pendingAirdropIds.append(pendingAirdropId)

        return self
    }

    /// clear the pending airdrop ids
    @discardableResult
    public func clearPendingAirdropIds() -> Self {
        self.pendingAirdropIds = []

        return self
    }

    internal override func transactionExecute(_ channel: GRPCChannel, _ request: Proto_Transaction) async throws
        -> Proto_TransactionResponse
    {
        try await Proto_TokenServiceAsyncClient(channel: channel).claimAirdrop(request)
    }

    internal override func toTransactionDataProtobuf(_ chunkInfo: ChunkInfo) -> Proto_TransactionBody.OneOf_Data {
        _ = chunkInfo.assertSingleTransaction()

        return .tokenClaimAirdrop(toProtobuf())
    }
}

extension TokenClaimAirdropTransaction: ToProtobuf {
    internal typealias Protobuf = Proto_TokenClaimAirdropTransactionBody

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.pendingAirdrops = pendingAirdropIds.map { $0.toProtobuf() }
        }
    }
}

extension TokenClaimAirdropTransaction {
    internal func toSchedulableTransactionData() -> Proto_SchedulableTransactionBody.OneOf_Data {
        .tokenClaimAirdrop(toProtobuf())
    }
}
