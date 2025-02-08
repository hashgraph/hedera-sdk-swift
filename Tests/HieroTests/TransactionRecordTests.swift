/*
 * ‌
 * Hedera Swift SDK
 *
 * Copyright (C) 2023 - 2023 Hedera Hashgraph, LLC
 *
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

internal final class TransactionRecordTests: XCTestCase {
    private func createReceipt() throws -> TransactionReceipt {
        try TransactionReceipt.init(
            transactionId: nil,
            status: Status.scheduleAlreadyDeleted,
            accountId: AccountId.fromString("1.2.3"),
            fileId: FileId.fromString("4.5.6"),
            contractId: ContractId.fromString("3.2.1"),
            topicId: TopicId.fromString("9.8.7"),
            topicSequenceNumber: 3,
            topicRunningHash: "running hash".data(using: .utf8),
            topicRunningHashVersion: 0,
            tokenId: TokenId.fromString("6.5.4"),
            totalSupply: 30,
            scheduleId: ScheduleId.fromString("1.1.1"),
            scheduledTransactionId: TransactionId.init(
                accountId: AccountId(5006),
                validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false),
            serials: [1, 2, 3],
            duplicates: [],
            children: [])
    }

    private func createRecord(_ prngBytes: Data?, _ prngNumber: UInt32?) throws -> TransactionRecord {
        try TransactionRecord.init(
            receipt: createReceipt(),
            transactionHash: "hello".data(using: .utf8)!,
            consensusTimestamp: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0),
            contractFunctionResult: ContractFunctionResult.init(
                contractId: ContractId.fromString("1.2.3"), bloom: Data.init(), gasUsed: 0, gas: 0, hbarAmount: 0,
                contractFunctionParametersBytes: Data.init(), bytes: Data.init(), signerNonce: nil),
            transfers: [Transfer.init(accountId: AccountId("4.4.4"), amount: 5)],
            tokenTransfers: [TokenId("6.6.6"): [AccountId("1.1.1"): 4]],
            tokenNftTransfers: [
                TokenId("4.4.4"): [
                    TokenNftTransfer.init(
                        tokenId: TokenId("4.4.4"), sender: AccountId("1.2.3"), receiver: AccountId("3.2.1"), serial: 4,
                        isApproved: true)
                ]
            ],
            transactionId: TransactionId(
                accountId: AccountId.fromString("3.3.3"),
                validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false),
            transactionMemo: "flook",
            transactionFee: 3000,
            scheduleRef: ScheduleId("3.3.3"),
            assessedCustomFees: [
                AssessedCustomFee.init(
                    amount: 4, tokenId: TokenId("4.5.6"), feeCollectorAccountId: AccountId("8.6.5"),
                    payerAccountIdList: [AccountId("3.3.3")])
            ],
            automaticTokenAssociations: [
                TokenAssociation.init(tokenId: TokenId("5.4.3"), accountId: AccountId("3.6.7"))
            ],
            parentConsensusTimestamp: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0),
            aliasKey: Resources.publicKey,
            children: [],
            duplicates: [],
            ethereumHash: "flook ethereum".data(using: .utf8)!,
            evmAddress: EvmAddress.fromBytes("0x000000000000000000".data(using: .utf8)!),
            prngBytes: prngBytes,
            prngNumber: prngNumber,
            pendingAirdropRecords: [
                PendingAirdropRecord.init(
                    pendingAirdropId: PendingAirdropId.init(
                        senderId: AccountId("0.2.3"), receiverId: AccountId("0.2.3"), tokenId: TokenId("0.0.2009")),
                    amount: 3)
            ])
    }

    internal func testSerialize() throws {
        let record = try createRecord("very random bytes".data(using: .utf8)!, nil)

        assertSnapshot(matching: record, as: .description)
    }

    internal func testSerialize2() throws {
        let record = try createRecord(nil, 4)

        assertSnapshot(matching: record, as: .description)
    }
}
