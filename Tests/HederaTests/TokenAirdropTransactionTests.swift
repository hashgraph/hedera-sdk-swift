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

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class TokenAirdropTransactionTests: XCTestCase {
    private static func makeTransaction() throws -> TokenAirdropTransaction {
        let tx = TokenAirdropTransaction()

        try tx.tokenTransfer(TokenId(num: 5005), AccountId(num: 5006), 400)
            .tokenTransferWithDecimals(TokenId(num: 5), AccountId(num: 5005), -800, 3)
            .tokenTransferWithDecimals(TokenId(num: 5), AccountId(num: 5007), -400, 3)
            .tokenTransfer(TokenId(num: 4), AccountId(num: 5008), 1)
            .tokenTransfer(TokenId(num: 4), AccountId(num: 5006), -1)
            .nftTransfer(TokenId(num: 3).nft(2), AccountId(num: 5008), AccountId(num: 5007))
            .nftTransfer(TokenId(num: 3).nft(1), AccountId(num: 5008), AccountId(num: 5007))
            .nftTransfer(TokenId(num: 3).nft(3), AccountId(num: 5008), AccountId(num: 5006))
            .nftTransfer(TokenId(num: 3).nft(4), AccountId(num: 5007), AccountId(num: 5006))
            .nftTransfer(TokenId(num: 2).nft(4), AccountId(num: 5007), AccountId(num: 5006))
            .approvedTokenTransfer(TokenId(num: 4), AccountId(num: 5006), 123)
            .approvedNftTransfer(TokenId(num: 4).nft(4), AccountId(num: 5005), AccountId(num: 5006))
            .transactionId(Resources.txId)
            .nodeAccountIds(Resources.nodeAccountIds)
            .maxTransactionFee(Hbar(2))
            .freeze()
            .sign(Resources.privateKey)

        return tx
    }

    func testSerialize() throws {
        let tx = try Self.makeTransaction().makeProtoBody()
        assertSnapshot(matching: tx, as: .description)
    }

    func testToFromBytes() throws {
        let tx = try Self.makeTransaction()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    func testFromProtoBody() throws {
        let protoData = Proto_TokenAirdropTransactionBody.with { proto in
            proto.tokenTransfers = [
                .with {
                    $0.token = TokenId(num: 5005).toProtobuf()
                    $0.transfers = [
                        .with {
                            $0.accountID = AccountId(num: 5008).toProtobuf()
                            $0.amount = 200
                        },
                        .with {
                            $0.accountID = AccountId(num: 5009).toProtobuf()
                            $0.amount = -100
                        },
                        .with {
                            $0.accountID = AccountId(num: 5010).toProtobuf()
                            $0.amount = 40
                        },
                        .with {
                            $0.accountID = AccountId(num: 5011).toProtobuf()
                            $0.amount = 20
                        },
                    ]
                    $0.nftTransfers = [
                        .with {
                            $0.senderAccountID = AccountId(num: 5010).toProtobuf()
                            $0.receiverAccountID = AccountId(num: 5011).toProtobuf()
                            $0.serialNumber = 1
                            $0.isApproval = true
                        }
                    ]
                    $0.expectedDecimals = .with { $0.value = 3 }
                }
            ]
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.tokenAirdrop = protoData
            proto.transactionID = Resources.txId.toProtobuf()
        }

        let tx = try TokenAirdropTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.tokenTransfers.count, 1)
        XCTAssertEqual(tx.tokenTransfers[TokenId(num: 5005)]?.count, 4)
        XCTAssertEqual(tx.tokenNftTransfers[TokenId(num: 5005)]?.count, 1)
    }

    func testGetSetTokenTransfers() throws {
        let tokenId = TokenId(num: 123)
        let accountId = AccountId(num: 456)
        let value: Int64 = 1000
        let tx = TokenAirdropTransaction()
        tx.tokenTransfer(tokenId, accountId, value)

        let tokenTransfers = tx.tokenTransfers

        XCTAssertTrue(tokenTransfers.keys.contains(tokenId))
        XCTAssertEqual(tokenTransfers.count, 1)
        XCTAssertEqual(value, tokenTransfers[tokenId]?[accountId])
    }

    func testGetSetNftTransfer() throws {
        let nftId = TokenId(num: 5005).nft(1)
        let sender = AccountId(num: 5006)
        let receiver = AccountId(num: 5011)
        let tx = TokenAirdropTransaction()
        tx.nftTransfer(nftId, sender, receiver)

        let nftTransfers = tx.tokenNftTransfers

        XCTAssertTrue(nftTransfers.keys.contains(nftId.tokenId))
        XCTAssertEqual(nftTransfers[nftId.tokenId]?.count, 1)
        XCTAssertEqual(sender, nftTransfers[nftId.tokenId]?[0].sender)
        XCTAssertEqual(receiver, nftTransfers[nftId.tokenId]?[0].receiver)
    }

    func testGetSetApprovedNftTransfer() throws {
        let nftId = TokenId(num: 5005).nft(1)
        let sender = AccountId(num: 5006)
        let receiver = AccountId(num: 123)
        let tx = TokenAirdropTransaction()
        tx.approvedNftTransfer(nftId, sender, receiver)

        let nftTransfers = tx.tokenNftTransfers

        XCTAssertTrue(nftTransfers.keys.contains(nftId.tokenId))
        XCTAssertEqual(nftTransfers[nftId.tokenId]?.count, 1)
        XCTAssertEqual(sender, nftTransfers[nftId.tokenId]?[0].sender)
        XCTAssertEqual(receiver, nftTransfers[nftId.tokenId]?[0].receiver)
    }

    func testGetSetApprovedTokenTransfer() throws {
        let tokenId = TokenId(num: 1420)
        let accountId = AccountId(num: 415)
        let value: Int64 = 1000
        let tx = TokenAirdropTransaction()
        tx.approvedTokenTransfer(tokenId, accountId, value)

        let tokenTransfers = tx.tokenTransfers

        XCTAssertTrue(tokenTransfers.keys.contains(tokenId))
        XCTAssertEqual(tokenTransfers.count, 1)
        XCTAssertEqual(value, tokenTransfers[tokenId]?[accountId])
    }

    func testGetSetTokenIdDecimals() throws {
        let nftId = TokenId(num: 5005).nft(1)
        let sender = AccountId(num: 5006)
        let receiver = AccountId(num: 123)
        let tx = TokenAirdropTransaction()
        tx.approvedNftTransfer(nftId, sender, receiver)

        let nftTransfers = tx.tokenNftTransfers

        XCTAssertTrue(nftTransfers.keys.contains(nftId.tokenId))
        XCTAssertEqual(nftTransfers[nftId.tokenId]?.count, 1)
        XCTAssertEqual(sender, nftTransfers[nftId.tokenId]?[0].sender)
        XCTAssertEqual(receiver, nftTransfers[nftId.tokenId]?[0].receiver)
    }
}
