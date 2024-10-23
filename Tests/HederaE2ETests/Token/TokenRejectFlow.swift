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

import Hedera
import XCTest

internal final class TokenRejectFlow: XCTestCase {
    internal func testBasicFlowFungible() async throws {
        let testEnv = try TestEnvironment.nonFree

        let op = testEnv.operator
        let fungibleToken = try await FungibleToken.create(testEnv, decimals: 3)
        let receiverAccount = try await Account.create(testEnv, Key.single(testEnv.operator.privateKey.publicKey), 0)

        // Manually associate fungible token
        let _ = try await TokenAssociateTransaction()
            .accountId(receiverAccount.id)
            .tokenIds([fungibleToken.id])
            .freezeWith(testEnv.client)
            .sign(receiverAccount.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        // Transfer tokens to the receiver
        let _ = try await TransferTransaction()
            .tokenTransfer(fungibleToken.id, op.accountId, -10)
            .tokenTransfer(fungibleToken.id, receiverAccount.id, 10)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        // Execute token reject flow
        let _ = try await Hedera.TokenRejectFlow()
            .ownerId(receiverAccount.id)
            .addTokenId(fungibleToken.id)
            .freezeWith(testEnv.client)
            .sign(receiverAccount.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        // Verify the tokens are transferred back to the treasury account
        let treasuryAccountBalance = try await AccountBalanceQuery()
            .accountId(op.accountId)
            .execute(testEnv.client)

        XCTAssertEqual(treasuryAccountBalance.tokenBalances[fungibleToken.id], 1_000_000)

        await assertThrowsHErrorAsync(
            try await TransferTransaction()
                .tokenTransfer(fungibleToken.id, op.accountId, -10)
                .tokenTransfer(fungibleToken.id, receiverAccount.id, 10)
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected error transferring tokens"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .tokenNotAssociatedToAccount)
        }

        try await fungibleToken.delete(testEnv)
        try await receiverAccount.delete(testEnv)
    }

    internal func testBasicFlowNft() async throws {
        let testEnv = try TestEnvironment.nonFree

        let op = testEnv.operator
        let receiverAccount = try await Account.create(testEnv, Key.single(testEnv.operator.privateKey.publicKey), 0)

        // Create and mint NFT
        let (nft, nftSerials) = try await createAndMintNft(testEnv: testEnv)

        // Associate nft
        let _ = try await TokenAssociateTransaction()
            .accountId(receiverAccount.id)
            .tokenIds([nft.id])
            .freezeWith(testEnv.client)
            .sign(receiverAccount.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        // Transfer nfts to the receiver
        let _ = try await TransferTransaction()
            .nftTransfer(nft.id.nft(nftSerials[0]), op.accountId, receiverAccount.id)
            .nftTransfer(nft.id.nft(nftSerials[1]), op.accountId, receiverAccount.id)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        // Execute token reject flow
        let _ = try await Hedera.TokenRejectFlow()
            .ownerId(receiverAccount.id)
            .nftIds([nft.id.nft(nftSerials[0]), nft.id.nft(nftSerials[1])])
            .freezeWith(testEnv.client)
            .sign(receiverAccount.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        // Verify the token is transferred back to the treasury account
        let nftTokenIdNftInfo = try await TokenNftInfoQuery()
            .nftId(nft.id.nft(nftSerials[1]))
            .execute(testEnv.client)

        XCTAssertEqual(nftTokenIdNftInfo.accountId, op.accountId)

        await assertThrowsHErrorAsync(
            try await TransferTransaction()
                .nftTransfer(nft.id.nft(nftSerials[1]), op.accountId, receiverAccount.id)
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected error transferring tokens"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .tokenNotAssociatedToAccount)
        }

        try await nft.delete(testEnv)
        try await receiverAccount.delete(testEnv)
    }

    internal func testRejectFlowForPartiallyOwnedNfts() async throws {
        let testEnv = try TestEnvironment.nonFree

        let op = testEnv.operator
        let receiverAccount = try await Account.create(testEnv, Key.single(testEnv.operator.privateKey.publicKey), 0)

        // Create and mint an nft
        let (nft1, nftSerials) = try await createAndMintNft(testEnv: testEnv)

        // Associate nft
        let _ = try await TokenAssociateTransaction()
            .accountId(receiverAccount.id)
            .tokenIds([nft1.id])
            .freezeWith(testEnv.client)
            .sign(receiverAccount.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        // Transfer nfts to the receiver
        let _ = try await TransferTransaction()
            .nftTransfer(nft1.id.nft(nftSerials[0]), op.accountId, receiverAccount.id)
            .nftTransfer(nft1.id.nft(nftSerials[1]), op.accountId, receiverAccount.id)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        await assertThrowsHErrorAsync(
            // Execute the token reject flow
            try await Hedera.TokenRejectFlow()
                .ownerId(receiverAccount.id)
                .addNftId(nft1.id.nft(nftSerials[1]))
                .freezeWith(testEnv.client)
                .sign(receiverAccount.key)
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected error rejecting token flow"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .accountStillOwnsNfts)
        }

        try await nft1.delete(testEnv)
    }
}

private func createAndMintNft(testEnv: NonfreeTestEnvironment) async throws -> (Nft, [UInt64]) {
    let nft = try await Nft.create(testEnv)
    let mintReceiptToken = try await TokenMintTransaction()
        .tokenId(nft.id)
        .metadata(testMetadata)
        .execute(testEnv.client)
        .getReceipt(testEnv.client)
    let nftSerials = try XCTUnwrap(mintReceiptToken.serials)
    return (nft, nftSerials)
}
