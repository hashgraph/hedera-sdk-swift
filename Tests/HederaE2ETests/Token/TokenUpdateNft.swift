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

import Hedera
import XCTest

internal final class TokenUpdateNfts: XCTestCase {
    internal func testUpdateNftMetadata() async throws {
        let testEnv = try TestEnvironment.nonFree

        let metadataKey = PrivateKey.generateEd25519()
        let nftCount = 4
        let initialMetadataList = [Data(Array(repeating: [9,1,6], count: (nftCount / [9,1,6].count) + 1).flatMap { $0 }.prefix(nftCount))]
        let updatedMetadata = Data([3,4])
        let updatedMetadataList = [Data(Array(repeating: [3,4], count: ((nftCount/2) / [3, 4].count) + 1).flatMap { $0 }.prefix(nftCount/2))]
        
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
        
        // Mint token
        let tokenMintTxReceipt = try await TokenMintTransaction()
            .metadata(initialMetadataList)
            .tokenId(tokenId)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        
        let nftSerials = try XCTUnwrap(tokenMintTxReceipt.serials)
        let metadataList = try await getMetadataList(testEnv.client, tokenId, nftSerials)
        
        XCTAssertEqual(metadataList, initialMetadataList)
        
        // Apply new serials & metadata Nft token
        let updatedNftTxReceipt = try await TokenUpdateNftsTransaction()
            .tokenId(tokenId)
            .serials(Array(nftSerials.prefix(2)))
            .metadata(updatedMetadata)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        
        let updatedSerials = Array(try XCTUnwrap(updatedNftTxReceipt.serials).prefix(2))
        let newMetadataList = try await getMetadataList(testEnv.client, tokenId, updatedSerials)
        
        XCTAssertEqual(newMetadataList, updatedMetadataList)
        
        let endingSerials = Array(try XCTUnwrap(updatedNftTxReceipt.serials).suffix(2))
        let endingMetadataList = try await getMetadataList(testEnv.client, tokenId, endingSerials)
        
        XCTAssertEqual(endingMetadataList, initialMetadataList.suffix(2))
    }

    internal func testUpdateNftMetadataAfterMetadataKeySet() async throws {
        let testEnv = try TestEnvironment.nonFree

        let metadataKey = PrivateKey.generateEd25519()
        let nftCount = 4
        let initialMetadataList = [Data(Array(repeating: [9,1,6], count: (nftCount / [9,1,6].count) + 1).flatMap { $0 }.prefix(nftCount))]
        let updatedMetadata = Data([3,4])
        let updatedMetadataList = [Data(Array(repeating: [3,4], count: ((nftCount/2) / [3, 4].count) + 1).flatMap { $0 }.prefix(nftCount/2))]
        
        // Create token without metadata key
        let tokenCreateTxReceipt = try await TokenCreateTransaction()
            .name("ffff")
            .symbol("F")
            .tokenType(TokenType.nonFungibleUnique)
            .treasuryAccountId(testEnv.operator.accountId)
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .supplyKey(.single(testEnv.operator.privateKey.publicKey))
            .expirationTime(.now + .minutes(5))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let tokenId = try XCTUnwrap(tokenCreateTxReceipt.tokenId)
        
        let tokenInfo = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(testEnv.client)
        
        XCTAssertEqual(tokenInfo.metadataKey, nil)
        
        // Update token to contain metadata key
        _ = try await TokenUpdateTransaction()
            .tokenId(tokenId)
            .metadataKey(.single(metadataKey.publicKey))
            .execute(testEnv.client)
        
        let tokenInfoAfterUpdate = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(testEnv.client)
                        
        XCTAssertEqual(tokenInfoAfterUpdate.metadataKey, .single(metadataKey.publicKey))
        
        // Mint token
        let tokenMintTxReceipt = try await TokenMintTransaction()
            .metadata(initialMetadataList)
            .tokenId(tokenId)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        
        let nftSerials = try XCTUnwrap(tokenMintTxReceipt.serials)
        let metadataListAfterMint = try await getMetadataList(testEnv.client, tokenId, nftSerials)
        
        XCTAssertEqual(metadataListAfterMint, initialMetadataList)
        
        // Update serials & metadata of Nft token, using metadata key to sign
        let updatedNftTxReceipt = try await TokenUpdateNftsTransaction()
            .tokenId(tokenId)
            .serials(Array(nftSerials.prefix(2)))
            .metadata(updatedMetadata)
            .sign(metadataKey)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        
        let updatedSerials = Array(try XCTUnwrap(updatedNftTxReceipt.serials).prefix(2))
        let newMetadataList = try await getMetadataList(testEnv.client, tokenId, updatedSerials)
        
        XCTAssertEqual(newMetadataList, updatedMetadataList)
    }
    
    internal func testCantUpdateMetadataNoSignedMetadataKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let metadataKey = PrivateKey.generateEd25519()
        let nftCount = 4
        let initialMetadataList = [Data(Array(repeating: [9,1,6], count: (nftCount / [9,1,6].count) + 1).flatMap { $0 }.prefix(nftCount))]
        let updatedMetadata = Data([3,4])
        
        // Create Token with metadata key
        let tokenCreateTxReceipt = try await TokenCreateTransaction()
            .name("ffff")
            .symbol("F")
            .tokenType(TokenType.nonFungibleUnique)
            .treasuryAccountId(testEnv.operator.accountId)
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .supplyKey(.single(testEnv.operator.privateKey.publicKey))
            .metadataKey(.single(testEnv.operator.privateKey.publicKey))
            .expirationTime(.now + .minutes(5))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let tokenId = try XCTUnwrap(tokenCreateTxReceipt.tokenId)
        
        let tokenInfo = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(testEnv.client)
        
        let setMetadataKey = try XCTUnwrap(tokenInfo.metadataKey)
        
        XCTAssertEqual(setMetadataKey, .single(metadataKey.publicKey))
        
        // Mint token
        let tokenMintTxReceipt = try await TokenMintTransaction()
            .metadata(initialMetadataList)
            .tokenId(tokenId)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        
        let nftSerials = try XCTUnwrap(tokenMintTxReceipt.serials)
                
        await assertThrowsHErrorAsync(
            // Should fail without signature of metadata key
            try await TokenUpdateNftsTransaction()
                .tokenId(tokenId)
                .serials(nftSerials)
                .metadata(updatedMetadata)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("\(error.kind) is not `.receiptStatus(status: _)`")
                return
            }

            XCTAssertEqual(status, .invalidSignature)
        }
    }
    
    internal func testCantUpdateMetadataNoSetMetadataKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let metadataKey = PrivateKey.generateEd25519()
        let nftCount = 4
        let initialMetadataList = [Data(Array(repeating: [9,1,6], count: (nftCount / [9,1,6].count) + 1).flatMap { $0 }.prefix(nftCount))]
        let updatedMetadata = Data([3,4])
        
        // Create token with no set metadata key
        let tokenCreateTxReceipt = try await TokenCreateTransaction()
            .name("ffff")
            .symbol("F")
            .tokenType(TokenType.nonFungibleUnique)
            .treasuryAccountId(testEnv.operator.accountId)
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .supplyKey(.single(testEnv.operator.privateKey.publicKey))
            .expirationTime(.now + .minutes(5))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let tokenId = try XCTUnwrap(tokenCreateTxReceipt.tokenId)
        
        let tokenInfo = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(testEnv.client)
        
        XCTAssertEqual(tokenInfo.metadataKey, nil)
        
        // Mint token
        let tokenMintTxReceipt = try await TokenMintTransaction()
            .metadata(initialMetadataList)
            .tokenId(tokenId)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        
        let nftSerials = try XCTUnwrap(tokenMintTxReceipt.serials)
        
        await assertThrowsHErrorAsync(
            // Should fail without setting metadata key when updating Nft
            try await TokenUpdateNftsTransaction()
                .tokenId(tokenId)
                .serials(nftSerials)
                .metadata(updatedMetadata)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
            
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("\(error.kind) is not `.receiptStatus(status: _)`")
                return
            }

            XCTAssertEqual(status, .tokenHasNoMetadataKey)
        }
    }
}

func getMetadataList(_ client: Client, _ tokenId: TokenId, _ serials: [UInt64]) async throws -> [Data] {
    // Use TaskGroup to handle concurrent fetches
    let metadataList: [Data] = try await withThrowingTaskGroup(of: Data.self, body: { group in
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
