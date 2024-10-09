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
import SwiftProtobuf

public class AbstractTokenTransferTransaction: Transaction {
    // avoid scope collisions by nesting :/
    struct Transfer: ValidateChecksums {
        let accountId: AccountId
        var amount: Int64
        let isApproval: Bool

        internal func validateChecksums(on ledgerId: LedgerId) throws {
            try accountId.validateChecksums(on: ledgerId)
        }
    }

    struct TokenTransfer: ValidateChecksums {
        let tokenId: TokenId
        var transfers: [AbstractTokenTransferTransaction.Transfer]
        var nftTransfers: [AbstractTokenTransferTransaction.NftTransfer]
        var expectedDecimals: UInt32?

        internal func validateChecksums(on ledgerId: LedgerId) throws {
            try tokenId.validateChecksums(on: ledgerId)
            try transfers.validateChecksums(on: ledgerId)
            try nftTransfers.validateChecksums(on: ledgerId)
        }
    }

    struct NftTransfer: ValidateChecksums {
        let senderAccountId: AccountId
        let receiverAccountId: AccountId
        let serial: UInt64
        let isApproval: Bool

        internal func validateChecksums(on ledgerId: LedgerId) throws {
            try senderAccountId.validateChecksums(on: ledgerId)
            try receiverAccountId.validateChecksums(on: ledgerId)
        }
    }

    var transfers: [AbstractTokenTransferTransaction.Transfer] = [] {
        willSet {
            ensureNotFrozen(fieldName: "transfers")
        }
    }

    public var tokenTransfers: [TokenId: [AccountId: Int64]] {
        Dictionary(
            tokenTransfersInner.lazy.map { item in
                (
                    item.tokenId,
                    Dictionary(
                        item.transfers.lazy.map { ($0.accountId, $0.amount) },
                        uniquingKeysWith: { first, _ in first }
                    )
                )
            },
            uniquingKeysWith: { (first, _) in first }
        )
    }

    public var tokenNftTransfers: [TokenId: [TokenNftTransfer]] {
        Dictionary(
            tokenTransfersInner.lazy.map { item in
                (
                    item.tokenId,
                    item.nftTransfers.map {
                        TokenNftTransfer(
                            tokenId: item.tokenId,
                            sender: $0.senderAccountId,
                            receiver: $0.receiverAccountId,
                            serial: $0.serial,
                            isApproved: $0.isApproval
                        )
                    }
                )
            },
            uniquingKeysWith: { (first, _) in first }
        )
    }

    internal var tokenTransfersInner: [AbstractTokenTransferTransaction.TokenTransfer] = [] {
        willSet {
            ensureNotFrozen(fieldName: "tokenTransfers")
        }
    }

    /// Extract the list of token id decimals.
    public var tokenDecimals: [TokenId: UInt32] {
        Dictionary(
            tokenTransfersInner.lazy.compactMap { elem in
                guard let decimals = elem.expectedDecimals else {
                    return nil
                }

                return (elem.tokenId, decimals)
            },
            uniquingKeysWith: { first, _ in first }
        )
    }

    // /// Create a new `AbstractTokenTransferTransaction`.
    // public override init() {
    //     super.init()
    // }

    /// Add a non-approved token transfer to the transaction.
    ///
    /// `amount` is in the lowest denomination for the token (if the token has `2` decimals this would be `0.01` tokens).
    @discardableResult
    public func tokenTransfer(_ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64) -> Self {
        doTokenTransfer(tokenId, accountId, amount, false)
    }

    /// Add an approved token transfer to the transaction.
    ///
    /// `amount` is in the lowest denomination for the token (if the token has `2` decimals this would be `0.01` tokens).
    @discardableResult
    public func approvedTokenTransfer(_ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64) -> Self {
        doTokenTransfer(tokenId, accountId, amount, true)
    }

    /// Add a non-approved token transfer with decimals to the transaction, ensuring that the token has `expectedDecimals` decimals.
    ///
    /// `amount` is _still_ in the lowest denomination, however,
    /// you will get an error if the token has a different amount of decimals than `expectedDecimals`.
    @discardableResult
    public func tokenTransferWithDecimals(
        _ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64, _ expectedDecimals: UInt32
    ) -> Self {
        doTokenTransferWithDecimals(tokenId, accountId, amount, false, expectedDecimals)
    }

    /// Add an approved token transfer with decimals to the transaction, ensuring that the token has `expectedDecimals` decimals.
    ///
    /// `amount` is _still_ in the lowest denomination, however,
    /// you will get an error if the token has a different amount of decimals than `expectedDecimals`.
    @discardableResult
    public func approvedTokenTransferWithDecimals(
        _ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64, _ expectedDecimals: UInt32
    ) -> Self {
        doTokenTransferWithDecimals(tokenId, accountId, amount, false, expectedDecimals)
    }

    /// Add a non-approved nft transfer to the transaction.
    @discardableResult
    public func nftTransfer(_ nftId: NftId, _ senderAccountId: AccountId, _ receiverAccountId: AccountId)
        -> Self
    {
        doNftTransfer(nftId, senderAccountId, receiverAccountId, false)
    }

    /// Add an approved nft transfer to the transaction.
    @discardableResult
    public func approvedNftTransfer(
        _ nftId: NftId, _ senderAccountId: AccountId, _ receiverAccountId: AccountId
    ) -> Self {
        doNftTransfer(nftId, senderAccountId, receiverAccountId, true)
    }

    private func doTokenTransfer(
        _ tokenId: TokenId,
        _ accountId: AccountId,
        _ amount: Int64,
        _ approved: Bool
    ) -> Self {
        let transfer = Transfer(accountId: accountId, amount: amount, isApproval: approved)

        if let firstIndex = tokenTransfersInner.firstIndex(where: { (tokenTransfer) in tokenTransfer.tokenId == tokenId
        }) {
            let existingTransfers = tokenTransfersInner[firstIndex].transfers

            if let existingTransferIndex = existingTransfers.firstIndex(where: {
                $0.accountId == accountId && $0.isApproval == approved
            }) {
                tokenTransfersInner[firstIndex].transfers[existingTransferIndex].amount += amount
            } else {
                tokenTransfersInner[firstIndex].expectedDecimals = nil
                tokenTransfersInner[firstIndex].transfers.append(transfer)
            }
        } else {
            tokenTransfersInner.append(
                TokenTransfer(
                    tokenId: tokenId,
                    transfers: [transfer],
                    nftTransfers: [],
                    expectedDecimals: nil
                ))
        }

        return self
    }

    private func doTokenTransferWithDecimals(
        _ tokenId: TokenId,
        _ accountId: AccountId,
        _ amount: Int64,
        _ approved: Bool,
        _ expectedDecimals: UInt32
    ) -> Self {
        let transfer = Transfer(accountId: accountId, amount: amount, isApproval: approved)

        if let firstIndex = tokenTransfersInner.firstIndex(where: { (tokenTransfer) in tokenTransfer.tokenId == tokenId
        }) {
            if tokenTransfersInner[firstIndex].expectedDecimals != nil
                && tokenTransfersInner[firstIndex].expectedDecimals != expectedDecimals
            {
                print(
                    "Token \(tokenId) has a different amount of decimals than expected. Expected \(expectedDecimals) but got \(tokenTransfersInner[firstIndex].expectedDecimals!)"
                )
                return self
            }

            let existingTransfers = tokenTransfersInner[firstIndex].transfers

            if let existingTransferIndex = existingTransfers.firstIndex(where: {
                $0.accountId == accountId && $0.isApproval == approved
            }) {
                tokenTransfersInner[firstIndex].transfers[existingTransferIndex].amount += amount
            } else {
                tokenTransfersInner[firstIndex].expectedDecimals = expectedDecimals
                tokenTransfersInner[firstIndex].transfers.append(transfer)
            }
        } else {
            tokenTransfersInner.append(
                TokenTransfer(
                    tokenId: tokenId,
                    transfers: [transfer],
                    nftTransfers: [],
                    expectedDecimals: expectedDecimals
                ))
        }

        return self
    }

    private func doNftTransfer(
        _ nftId: NftId,
        _ senderAccountId: AccountId,
        _ receiverAccountId: AccountId,
        _ approved: Bool
    ) -> Self {
        let transfer = NftTransfer(
            senderAccountId: senderAccountId,
            receiverAccountId: receiverAccountId,
            serial: nftId.serial,
            isApproval: approved
        )

        if let index = tokenTransfersInner.firstIndex(where: { transfer in transfer.tokenId == nftId.tokenId }) {
            var tmp = tokenTransfersInner[index]
            tmp.nftTransfers.append(transfer)
            tokenTransfersInner[index] = tmp
        } else {
            tokenTransfersInner.append(
                TokenTransfer(
                    tokenId: nftId.tokenId,
                    transfers: [],
                    nftTransfers: [transfer],
                    expectedDecimals: nil
                )
            )
        }

        return self
    }

    internal func sortTransfers() -> [TokenTransfer] {
        var transferLists = tokenTransfersInner

        // Sort token transfers by token ID
        transferLists.sort { a, b in
            if a.tokenId.shard != b.tokenId.shard {
                return a.tokenId.shard < b.tokenId.shard
            }
            if a.tokenId.realm != b.tokenId.realm {
                return a.tokenId.realm < b.tokenId.realm
            }
            return a.tokenId.num < b.tokenId.num
        }

        // Sort transfers within each TokenTransfer
        for index in transferLists.indices {
            transferLists[index].transfers.sort { (a: Transfer, b: Transfer) in
                if a.accountId.shard != b.accountId.shard {
                    return a.accountId.shard < b.accountId.shard
                }
                if a.accountId.realm != b.accountId.realm {
                    return a.accountId.realm < b.accountId.realm
                }
                if a.accountId.num != b.accountId.num {
                    return a.accountId.num < b.accountId.num
                }
                return a.isApproval && !b.isApproval
            }

            transferLists[index].nftTransfers.sort { $0.serial < $1.serial }
        }

        return transferLists
    }

    internal override func validateChecksums(on ledgerId: LedgerId) throws {
        try transfers.validateChecksums(on: ledgerId)
        try tokenTransfersInner.validateChecksums(on: ledgerId)
        try super.validateChecksums(on: ledgerId)
    }
}

extension AbstractTokenTransferTransaction.Transfer: TryProtobufCodable {
    internal typealias Protobuf = Proto_AccountAmount

    internal init(protobuf proto: Protobuf) throws {
        self.init(
            accountId: try .fromProtobuf(proto.accountID),
            amount: proto.amount,
            isApproval: proto.isApproval
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.accountID = accountId.toProtobuf()
            proto.amount = amount
            proto.isApproval = isApproval
        }
    }
}

extension AbstractTokenTransferTransaction.TokenTransfer: TryProtobufCodable {
    internal typealias Protobuf = Proto_TokenTransferList

    internal init(protobuf proto: Protobuf) throws {
        self.init(
            tokenId: .fromProtobuf(proto.token),
            transfers: try .fromProtobuf(proto.transfers),
            nftTransfers: try .fromProtobuf(proto.nftTransfers),
            expectedDecimals: proto.hasExpectedDecimals ? proto.expectedDecimals.value : nil
        )
        transfers = try .fromProtobuf(proto.transfers)

    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.token = tokenId.toProtobuf()
            proto.transfers = transfers.toProtobuf()
            proto.nftTransfers = nftTransfers.toProtobuf()
            if let expectedDecimals = expectedDecimals {
                proto.expectedDecimals = Google_Protobuf_UInt32Value(expectedDecimals)
            }
        }
    }
}

extension AbstractTokenTransferTransaction.NftTransfer: TryProtobufCodable {
    internal typealias Protobuf = Proto_NftTransfer

    internal init(protobuf proto: Protobuf) throws {
        self.init(
            senderAccountId: try .fromProtobuf(proto.senderAccountID),
            receiverAccountId: try .fromProtobuf(proto.receiverAccountID),
            serial: UInt64(proto.serialNumber),
            isApproval: proto.isApproval
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.senderAccountID = senderAccountId.toProtobuf()
            proto.receiverAccountID = receiverAccountId.toProtobuf()
            proto.serialNumber = Int64(bitPattern: serial)
            proto.isApproval = isApproval
        }
    }
}

extension TokenNftTransfer {
    fileprivate init(nftTransfer: TransferTransaction.NftTransfer, withTokenId tokenId: TokenId) {
        self.init(
            tokenId: tokenId,
            sender: nftTransfer.senderAccountId,
            receiver: nftTransfer.receiverAccountId,
            serial: nftTransfer.serial,
            isApproved: nftTransfer.isApproval
        )
    }
}
