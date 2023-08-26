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

import GRPC
import HederaProtobufs
import SwiftProtobuf

/// Transfers cryptocurrency among two or more accounts by making the desired adjustments to their
/// balances.
///
/// Each transfer list can specify up to 10 adjustments. Each negative amount is withdrawn
/// from the corresponding account (a sender), and each positive one is added to the corresponding
/// account (a receiver). The amounts list must sum to zero.
///
///
/// All transfers are in the lowest denomination, for `Hbar` that is tinybars (although `Hbar` handles this itself).
///
/// As an example:
/// For a fungible token with `3` decimals (and let's say the symbol is `ƒ`), transferring `1` _always_ transfers `0.001 ƒ`.
public final class TransferTransaction: Transaction {
    // avoid scope collisions by nesting :/
    fileprivate struct Transfer: ValidateChecksums {
        let accountId: AccountId
        let amount: Int64
        let isApproval: Bool

        internal func validateChecksums(on ledgerId: LedgerId) throws {
            try accountId.validateChecksums(on: ledgerId)
        }
    }

    fileprivate struct TokenTransfer: ValidateChecksums {
        let tokenId: TokenId
        var transfers: [TransferTransaction.Transfer]
        var nftTransfers: [TransferTransaction.NftTransfer]
        var expectedDecimals: UInt32?

        internal func validateChecksums(on ledgerId: LedgerId) throws {
            try tokenId.validateChecksums(on: ledgerId)
            try transfers.validateChecksums(on: ledgerId)
            try nftTransfers.validateChecksums(on: ledgerId)
        }
    }

    fileprivate struct NftTransfer: ValidateChecksums {
        let senderAccountId: AccountId
        let receiverAccountId: AccountId
        let serial: UInt64
        let isApproval: Bool

        internal func validateChecksums(on ledgerId: LedgerId) throws {
            try senderAccountId.validateChecksums(on: ledgerId)
            try receiverAccountId.validateChecksums(on: ledgerId)
        }
    }

    private var transfers: [TransferTransaction.Transfer] = [] {
        willSet {
            ensureNotFrozen(fieldName: "transfers")
        }
    }

    public var hbarTransfers: [AccountId: Hbar] {
        Dictionary(
            transfers.lazy.map { ($0.accountId, .fromTinybars($0.amount)) },
            uniquingKeysWith: { (first, second) in first })
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
                    item.nftTransfers.map { TokenNftTransfer(nftTransfer: $0, withTokenId: item.tokenId) }
                )
            },
            uniquingKeysWith: { (first, _) in first }
        )
    }

    private var tokenTransfersInner: [TransferTransaction.TokenTransfer] = [] {
        willSet {
            ensureNotFrozen(fieldName: "tokenTransfers")
        }
    }

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

    /// Create a new `TransferTransaction`.
    public override init() {
        super.init()
    }

    internal init(protobuf proto: Proto_TransactionBody, _ data: Proto_CryptoTransferTransactionBody) throws {
        // init fields
        transfers = try .fromProtobuf(data.transfers.accountAmounts)
        tokenTransfersInner = try .fromProtobuf(data.tokenTransfers)

        try super.init(protobuf: proto)
    }

    /// Add a non-approved hbar transfer to the transaction.
    @discardableResult
    public func hbarTransfer(_ accountId: AccountId, _ amount: Hbar) -> Self {
        doHbarTransfer(accountId, amount.toTinybars(), false)
    }

    /// Add an approved hbar transfer to the transaction.
    @discardableResult
    public func approvedHbarTransfer(_ accountId: AccountId, _ amount: Hbar) -> Self {
        doHbarTransfer(accountId, amount.toTinybars(), true)
    }

    /// Add a non-approved token transfer to the transaction.
    ///
    /// `amount` is in the lowest denomination for the token (if the token has `2` decimals this would be `0.01` tokens).
    @discardableResult
    public func tokenTransfer(_ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64) -> Self {
        doTokenTransfer(tokenId, accountId, amount, false, nil)
    }

    /// Add an approved token transfer to the transaction.
    ///
    /// `amount` is in the lowest denomination for the token (if the token has `2` decimals this would be `0.01` tokens).
    @discardableResult
    public func approvedTokenTransfer(_ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64) -> Self {
        doTokenTransfer(tokenId, accountId, amount, true, nil)
    }

    /// Add a non-approved token transfer with decimals to the transaction, ensuring that the token has `expectedDecimals` decimals.
    ///
    /// `amount` is _still_ in the lowest denomination, however,
    /// you will get an error if the token has a different amount of decimals than `expectedDecimals`.
    @discardableResult
    public func tokenTransferWithDecimals(
        _ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64, _ expectedDecimals: UInt32
    ) -> Self {
        doTokenTransfer(tokenId, accountId, amount, false, expectedDecimals)
    }

    /// Add an approved token transfer with decimals to the transaction, ensuring that the token has `expectedDecimals` decimals.
    ///
    /// `amount` is _still_ in the lowest denomination, however,
    /// you will get an error if the token has a different amount of decimals than `expectedDecimals`.
    @discardableResult
    public func approvedTokenTransferWithDecimals(
        _ tokenId: TokenId, _ accountId: AccountId, _ amount: Int64, _ expectedDecimals: UInt32
    ) -> Self {
        doTokenTransfer(tokenId, accountId, amount, false, expectedDecimals)
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

    private func doHbarTransfer(
        _ accountId: AccountId,
        _ amount: Int64,
        _ approved: Bool
    ) -> Self {
        transfers.append(Transfer(accountId: accountId, amount: amount, isApproval: approved))

        return self
    }

    private func doTokenTransfer(
        _ tokenId: TokenId,
        _ accountId: AccountId,
        _ amount: Int64,
        _ approved: Bool,
        _ expectedDecimals: UInt32?
    ) -> Self {
        let transfer = Transfer(accountId: accountId, amount: amount, isApproval: approved)

        if let firstIndex = tokenTransfersInner.firstIndex(where: { (tokenTransfer) in tokenTransfer.tokenId == tokenId
        }) {
            tokenTransfersInner[firstIndex].expectedDecimals = expectedDecimals
            tokenTransfersInner[firstIndex].transfers.append(transfer)
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

    internal override func validateChecksums(on ledgerId: LedgerId) throws {
        try transfers.validateChecksums(on: ledgerId)
        try tokenTransfersInner.validateChecksums(on: ledgerId)
        try super.validateChecksums(on: ledgerId)
    }

    internal override func transactionExecute(_ channel: GRPCChannel, _ request: Proto_Transaction) async throws
        -> Proto_TransactionResponse
    {
        try await Proto_CryptoServiceAsyncClient(channel: channel).cryptoTransfer(request)
    }

    internal override func toTransactionDataProtobuf(_ chunkInfo: ChunkInfo) -> Proto_TransactionBody.OneOf_Data {
        _ = chunkInfo.assertSingleTransaction()

        return .cryptoTransfer(toProtobuf())
    }
}

extension TransferTransaction.Transfer: TryProtobufCodable {
    fileprivate typealias Protobuf = Proto_AccountAmount

    fileprivate init(protobuf proto: Protobuf) throws {
        self.init(
            accountId: try .fromProtobuf(proto.accountID),
            amount: proto.amount,
            isApproval: proto.isApproval
        )
    }

    fileprivate func toProtobuf() -> Protobuf {
        .with { proto in
            proto.accountID = accountId.toProtobuf()
            proto.amount = amount
            proto.isApproval = isApproval
        }
    }
}

extension TransferTransaction.TokenTransfer: TryProtobufCodable {
    fileprivate typealias Protobuf = Proto_TokenTransferList

    fileprivate init(protobuf proto: Protobuf) throws {
        self.init(
            tokenId: .fromProtobuf(proto.token),
            transfers: try .fromProtobuf(proto.transfers),
            nftTransfers: try .fromProtobuf(proto.nftTransfers),
            expectedDecimals: proto.hasExpectedDecimals ? proto.expectedDecimals.value : nil
        )
        transfers = try .fromProtobuf(proto.transfers)

    }

    fileprivate func toProtobuf() -> Protobuf {
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

extension TransferTransaction.NftTransfer: TryProtobufCodable {
    fileprivate typealias Protobuf = Proto_NftTransfer

    fileprivate init(protobuf proto: Protobuf) throws {
        self.init(
            senderAccountId: try .fromProtobuf(proto.senderAccountID),
            receiverAccountId: try .fromProtobuf(proto.receiverAccountID),
            serial: UInt64(proto.serialNumber),
            isApproval: proto.isApproval
        )
    }

    fileprivate func toProtobuf() -> Protobuf {
        .with { proto in
            proto.senderAccountID = senderAccountId.toProtobuf()
            proto.receiverAccountID = receiverAccountId.toProtobuf()
            proto.serialNumber = Int64(bitPattern: serial)
            proto.isApproval = isApproval
        }
    }
}

extension TransferTransaction: ToProtobuf {
    internal typealias Protobuf = Proto_CryptoTransferTransactionBody

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.transfers = .with { $0.accountAmounts = transfers.toProtobuf() }
            proto.tokenTransfers = tokenTransfersInner.toProtobuf()
        }
    }
}

extension TransferTransaction {
    internal func toSchedulableTransactionData() -> Proto_SchedulableTransactionBody.OneOf_Data {
        .cryptoTransfer(toProtobuf())
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
