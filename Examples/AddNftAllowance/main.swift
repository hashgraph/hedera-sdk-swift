/*
 * Hedera Swift SDK
 *
 * Copyright (C) 2022 - 2024 Hedera Hashgraph, LLC
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
 */

import Hedera
import SwiftDotenv

@main
internal enum Program {
    internal static func main() async throws {
        let env = try Dotenv.load()
        let client = try Client.forName(env.networkName)

        client.setOperator(env.operatorAccountId, env.operatorKey)

        // Step 1: Create an NFT
        let nftCreateReceipt = try await TokenCreateTransaction()
            .tokenName("HIP-336 NFT1")
            .tokenSymbol("HIP336NFT1")
            .tokenType(.nonFungibleUnique)
            .decimals(0)
            .initialSupply(0)
            .maxSupply(10)
            .treasuryAccountId(env.operatorAccountId)
            .adminKey(env.operatorKey.publicKey)
            .supplyKey(env.operatorKey.publicKey)
            .freezeWith(client)
            .execute(client)
            .getReceipt(client)

        guard let nftTokenId = nftCreateReceipt.tokenId else {
            fatalError("Failed to create NFT")
        }

        print("Created NFT with token ID: \(nftTokenId)")

        // Step 2: Mint NFTs
        let cids = [
            "QmNPCiNA3Dsu3K5FxDPMG5Q3fZRwVTg14EXA92uqEeSRXn",
            "QmZ4dgAgt8owvnULxnKxNe8YqpavtVCXmc1Lt2XajFpJs9",
            "QmPzY5GxevjyfMUF5vEAjtyRoigzWp47MiKAtLBduLMC1T",
        ]

        for cid in cids {
            let mintReceipt = try await TokenMintTransaction()
                .tokenId(nftTokenId)
                .metadata(cid.data(using: .utf8)!)
                .freezeWith(client)
                .execute(client)
                .getReceipt(client)

            guard let serials = mintReceipt.serials else {
                fatalError("Failed to mint NFT")
            }

            print("Minted NFT (token ID: \(nftTokenId)) with serial: \(serials.first!)")
        }

        // Step 3: Create spender and receiver accounts
        let spenderKey = PrivateKey.generateEd25519()
        let receiverKey = PrivateKey.generateEd25519()

        let spenderAccountId = try await AccountCreateTransaction()
            .key(spenderKey.publicKey)
            .initialBalance(Hbar(2))
            .execute(client)
            .getReceipt(client)
            .accountId!

        let receiverAccountId = try await AccountCreateTransaction()
            .key(receiverKey.publicKey)
            .initialBalance(Hbar(2))
            .execute(client)
            .getReceipt(client)
            .accountId!

        print("Created spender account ID: \(spenderAccountId), receiver account ID: \(receiverAccountId)")

        // Step 4: Associate spender and receiver with the NFT
        try await TokenAssociateTransaction()
            .accountId(spenderAccountId)
            .tokenIds([nftTokenId])
            .freezeWith(client)
            .sign(spenderKey)
            .execute(client)
            .getReceipt(client)

        try await TokenAssociateTransaction()
            .accountId(receiverAccountId)
            .tokenIds([nftTokenId])
            .freezeWith(client)
            .sign(receiverKey)
            .execute(client)
            .getReceipt(client)

        print("Associated spender and receiver accounts with NFT")

        // Step 5: Approve NFT allowance for spender
        try await AccountAllowanceApproveTransaction()
            .approveTokenNftAllowance(NftId(tokenId: nftTokenId, serial: 1), env.operatorAccountId, spenderAccountId)
            .approveTokenNftAllowance(NftId(tokenId: nftTokenId, serial: 2), env.operatorAccountId, spenderAccountId)
            .execute(client)

        print("Approved NFT allowance for spender")

        // Step 6: Transfer NFT using approved allowance
        let transferReceipt = try await TransferTransaction()
            .addApprovedNftTransfer(NftId(tokenId: nftTokenId, serial: 1), env.operatorAccountId, receiverAccountId)
            .freezeWith(client)
            .sign(spenderKey)
            .execute(client)
            .getReceipt(client)

        print("Transfer successful with status: \(transferReceipt.status)")

        // Step 7: Revoke allowance
        try await AccountAllowanceDeleteTransaction()
            .deleteAllTokenNftAllowances(NftId(tokenId: nftTokenId, serial: 2), env.operatorAccountId)
            .execute(client)

        print("Revoked NFT allowance")

        // Step 8: Attempt transfer after revoking allowance
        do {
            _ = try await TransferTransaction()
                .addApprovedNftTransfer(NftId(tokenId: nftTokenId, serial: 2), env.operatorAccountId, receiverAccountId)
                .freezeWith(client)
                .sign(spenderKey)
                .execute(client)

            print("Transfer after revoking allowance should have failed")
        } catch {
            print("Expected failure: \(error)")
        }

        // Cleanup resources by deleting tokens, accounts, etc.
        // Implement cleanup steps...
    }
}

extension Environment {
    /// Account ID for the operator to use in this example.
    internal var operatorAccountId: AccountId {
        AccountId(self["OPERATOR_ID"]!.stringValue)!
    }

    /// Private key for the operator to use in this example.
    internal var operatorKey: PrivateKey {
        PrivateKey(self["OPERATOR_KEY"]!.stringValue)!
    }

    /// The name of the Hedera network this example should run against.
    internal var networkName: String {
        self["HEDERA_NETWORK"]?.stringValue ?? "testnet"
    }
}
