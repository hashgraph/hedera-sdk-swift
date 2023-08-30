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

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal class AccountUpdateTransactionTests: XCTestCase {
    private static let accountId: AccountId = 2002
    private static let autoRenewPeriod: Duration = .hours(10)
    private static let expirationTime = Timestamp(seconds: 1_554_158_543, subSecondNanos: 0)
    private static let receiverSignatureRequired = false
    private static let accountMemo = "Some memo"
    private static let stakedAccountId: AccountId = "0.0.3"
    private static let stakedNodeId: UInt64 = 4

    private static func makeTransaction() throws -> AccountUpdateTransaction {
        let tx = AccountUpdateTransaction()

        tx.proxyAccountIdInner = 1001

        return
            try tx
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .accountId(accountId)
            .autoRenewPeriod(autoRenewPeriod)
            .expirationTime(expirationTime)
            .receiverSignatureRequired(receiverSignatureRequired)
            .accountMemo(accountMemo)
            .maxTransactionFee(.fromTinybars(100_000))
            .stakedAccountId(stakedAccountId)
            .freeze()
    }

    private static func makeTransaction2() throws -> AccountUpdateTransaction {
        let tx = AccountUpdateTransaction()

        tx.proxyAccountIdInner = 1001

        return
            try tx
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .accountId(accountId)
            .autoRenewPeriod(autoRenewPeriod)
            .expirationTime(expirationTime)
            .receiverSignatureRequired(receiverSignatureRequired)
            .accountMemo(accountMemo)
            .maxTransactionFee(.fromTinybars(100_000))
            .stakedNodeId(stakedNodeId)
            .freeze()
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

    internal func testSerialize2() throws {
        let tx = try Self.makeTransaction2().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytes2() throws {
        let tx = try Self.makeTransaction2()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testFromProtoBody() throws {
        let protoData = Proto_CryptoUpdateTransactionBody.with { proto in
            proto.accountIdtoUpdate = Self.accountId.toProtobuf()
            proto.autoRenewPeriod = Self.autoRenewPeriod.toProtobuf()
            proto.expirationTime = Self.expirationTime.toProtobuf()
            proto.receiverSigRequiredWrapper = .init(Self.receiverSignatureRequired)
            proto.memo = .init(Self.accountMemo)
            proto.stakedAccountID = Self.stakedAccountId.toProtobuf()
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.cryptoUpdateAccount = protoData
            proto.transactionID = Resources.txId.toProtobuf()
        }

        let tx = try AccountUpdateTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.accountId, Self.accountId)
        XCTAssertEqual(tx.autoRenewPeriod, Self.autoRenewPeriod)
        XCTAssertEqual(tx.expirationTime, Self.expirationTime)
        XCTAssertEqual(tx.receiverSignatureRequired, Self.receiverSignatureRequired)
        XCTAssertEqual(tx.accountMemo, Self.accountMemo)
        XCTAssertEqual(tx.stakedAccountId, Self.stakedAccountId)
        XCTAssertEqual(tx.stakedNodeId, nil)
    }

    internal func testGetSetAccountId() {
        let tx = AccountUpdateTransaction()
        tx.accountId(Self.accountId)

        XCTAssertEqual(tx.accountId, Self.accountId)
    }

    internal func testGetSetAutoRenewPeriod() {
        let tx = AccountUpdateTransaction()
        tx.autoRenewPeriod(Self.autoRenewPeriod)

        XCTAssertEqual(tx.autoRenewPeriod, Self.autoRenewPeriod)
    }

    internal func testGetSetExpirationTime() {
        let tx = AccountUpdateTransaction()
        tx.expirationTime(Self.expirationTime)

        XCTAssertEqual(tx.expirationTime, Self.expirationTime)
    }

    internal func testGetSetReceiverSignatureRequired() {
        let tx = AccountUpdateTransaction()
        tx.receiverSignatureRequired(Self.receiverSignatureRequired)

        XCTAssertEqual(tx.receiverSignatureRequired, Self.receiverSignatureRequired)
    }

    internal func testGetSetAccountMemo() {
        let tx = AccountUpdateTransaction()
        tx.accountMemo(Self.accountMemo)

        XCTAssertEqual(tx.accountMemo, Self.accountMemo)
    }

    internal func testGetSetStakedAccountId() {
        let tx = AccountUpdateTransaction()
        tx.stakedAccountId(Self.stakedAccountId)

        XCTAssertEqual(tx.stakedAccountId, Self.stakedAccountId)
    }

    internal func testGetSetStakedNodeId() {
        let tx = AccountUpdateTransaction()
        tx.stakedNodeId(Self.stakedNodeId)

        XCTAssertEqual(tx.stakedNodeId, Self.stakedNodeId)
    }
}
