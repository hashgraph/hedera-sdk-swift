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
        let nftCount = 4
        let initialMetadataList = [
            Data(Array(repeating: [9, 1, 6], count: (nftCount / [9, 1, 6].count) + 1).flatMap { $0 }.prefix(nftCount))
        ]
        let updatedMetadata = Data([3, 4])

        // Create Token with metadata key included
        let tokenCreateTxReceipt = try await TokenCreateTransaction()
            .name("ffff")
            .symbol("F")
            .tokenType(TokenType.nonFungibleUnique)
            .treasuryAccountId(testEnv.operator.accountId)
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .supplyKey(.single(testEnv.operator.privateKey.publicKey))
            .metadataKey(.single(metadataKey.publicKey))
            .expirationTime(.now + .minutes(5))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let tokenId = try XCTUnwrap(tokenCreateTxReceipt.tokenId)

        // Mint Token
        let tokenMintTxReceipt = try await TokenMintTransaction()
            .metadata(initialMetadataList)
            .tokenId(tokenId)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let serials = try XCTUnwrap(tokenMintTxReceipt.serials)

        print("Metadata after mint= \(try await getMetadataList(testEnv.client, tokenId, serials))")

        // Apply new serials & metadata Nft token
        let updatedNftTxReceipt = try await TokenUpdateNftsTransaction()
            .tokenId(tokenId)
            .serials(Array(nftSerials.prefix(2)))
            .metadata(updatedMetadata)
            .sign(metadataKey)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let updatedSerials = try XCTUnwrap(updatedNftTxReceipt.serials)

        print("Metadata after mint= \(try await getMetadataList(testEnv.client, tokenId, updatedSerials))")
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
