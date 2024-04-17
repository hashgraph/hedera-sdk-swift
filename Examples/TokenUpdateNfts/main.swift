/*
 * ‌
 * Hedera Swift SDK
 *
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
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
 *
 */

import Foundation
import Hedera
import SwiftDotenv

@main
internal enum Program {
    internal static func main() async throws {
        let env = try Dotenv.load()
        let client = try Client.forName(env.networkName)

        client.setOperator(env.operatorAccountId, env.operatorKey)

        let metadataKey = PrivateKey.generateEd25519()
        print("Generated metadata key= \(metadataKey)")

        let metadata = Data([1])
        let newMetadata = Data([1, 2])

        // Create Token with metadata key included
        let tokenCreateTxReceipt = try await TokenCreateTransaction()
            .name("Test")
            .symbol("T")
            .tokenType(TokenType.nonFungibleUnique)
            .treasuryAccountId(env.operatorAccountId)
            .adminKey(.single(env.operatorKey.publicKey))
            .supplyKey(.single(env.operatorKey.publicKey))
            .metadataKey(.single(metadataKey.publicKey))
            .expirationTime(.now + .minutes(5))
            .execute(client)
            .getReceipt(client)

        print("Status of token create transaction= \(tokenCreateTxReceipt.status)")

        // Token ID created for the NFT collection.
        let tokenId = tokenCreateTxReceipt.tokenId!

        let tokenInfo = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(client)

        print("Token metadata key= \(tokenInfo.metadataKey!)")

        // Mint Token
        let tokenMintTx = TokenMintTransaction()
            .metadata([metadata])
            .tokenId(tokenId)

        print("Set metadata= \(tokenMintTx.metadata)")

        let tokenMintResponse = try await tokenMintTx.execute(client)

        // Get receipt for mint token transaction
        let tokenMintReceipt = try await tokenMintResponse.getReceipt(client)

        print("Status of token mint transaction= \(tokenMintReceipt.status)")

        let nftId = NftId(tokenId: tokenId, serial: tokenMintReceipt.serials!.first!)

        let nftInfo = try await TokenNftInfoQuery()
            .nftId(nftId)
            .execute(client)

        print("Current metadata= \(nftInfo)")

        let accountCreateTx = try await AccountCreateTransaction()
            .key(.single(env.operatorKey.publicKey))
            .initialBalance(.fromTinybars(1))
            .execute(client)
            .getReceipt(client)

        let newAccountId = accountCreateTx.accountId!

        let _ = try await TransferTransaction()
            .nftTransfer(nftId, env.operatorAccountId, newAccountId)
            .execute(client)

        // Apply new serials & metadata Nft token
        let tokenUpdateNftsTx = try TokenUpdateNftsTransaction()
            .tokenId(tokenId)
            .serials(tokenMintReceipt.serials!)
            .metadata(newMetadata)
            .freezeWith(client)

        let tokenUpdateNftsResponse = try await tokenUpdateNftsTx.sign(metadataKey).execute(
            client)

        // Get receipt for update nfts metadata transaction
        let tokenUpdateNftsReceipt = try await tokenUpdateNftsResponse.getReceipt(client)

        print("Status of token update nfts metadata transaction= \(tokenUpdateNftsReceipt.status)")

        let newNftInfo = try await TokenNftInfoQuery()
            .nftId(nftId)
            .execute(client)

        print("Updated metadata= \(newNftInfo.metadata)")

    }
}

func getMetadataList(_ client: Client, _ tokenId: TokenId, _ serials: [UInt64]) async throws -> [Data] {
    // Use TaskGroup to handle concurrent fetches
    let metadataList: [Data] = try await withThrowingTaskGroup(
        of: Data.self,
        body: { group in
            var results = [Data]()

            // Iterate over serials, launching a new task for each
            for serial in serials {
                group.addTask {
                    let nftId = NftId(tokenId: tokenId, serial: UInt64(serial))
                    // Execute the query and return the result
                    // This assumes an async `execute` function that returns metadata or throws an error
                    return try await TokenNftInfoQuery().nftId(nftId).execute(client).metadata
                }
            }

            // Collect results from all tasks
            for try await result in group {
                results.append(result)
            }

            return results
        })

    return metadataList
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

    /// The name of the hedera network this example should be ran against.
    ///
    /// Testnet by default.
    internal var networkName: String {
        self["HEDERA_NETWORK"]?.stringValue ?? "testnet"
    }
}
