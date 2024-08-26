/*
 * ‌
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

        // Defaults the operator account ID and key such that all generated transactions will be paid for
        // by this account and be signed by this key
        client.setOperator(env.operatorAccountId, env.operatorKey)

        // Generate a higher-privileged key.
        let adminKey = PrivateKey.generateEd25519()

        // Generate the lower-privileged keys that will be modified.
        // Note: Lower-privileged keys are Wipe, Supply, and updated Supply key..
        let supplyKey = PrivateKey.generateEd25519()
        let wipeKey = PrivateKey.generateEd25519()
        let newSupplyKey = PrivateKey.generateEd25519()

        let unusableKey = try PublicKey.fromStringEd25519(
            "0x0000000000000000000000000000000000000000000000000000000000000000")

        // Create an NFT token with admin, wipe, and supply key.
        let tokenId = try await TokenCreateTransaction()
            .name("Example NFT")
            .symbol("ENFT")
            .tokenType(TokenType.nonFungibleUnique)
            .treasuryAccountId(env.operatorAccountId)
            .adminKey(.single(adminKey.publicKey))
            .wipeKey(.single(wipeKey.publicKey))
            .supplyKey(.single(supplyKey.publicKey))
            .expirationTime(Timestamp.now + .minutes(5))
            .freezeWith(client)
            .sign(adminKey)
            .execute(client)
            .getReceipt(client)
            .tokenId!

        let tokenInfo = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(client)

        print("Admin Key: \(tokenInfo.adminKey!)")
        print("Wipe Key: \(tokenInfo.wipeKey!)")
        print("Supply Key: \(tokenInfo.supplyKey!)")

        print("------------------------------------")
        print("Removing Wipe Key...")

        // Remove the wipe key with empty Keylist, signing with the admin key.
        let _ = try await TokenUpdateTransaction()
            .tokenId(tokenId)
            .wipeKey(.keyList([]))
            .keyVerificationMode(TokenKeyValidation.fullValidation)
            .freezeWith(client)
            .sign(adminKey)
            .execute(client)
            .getReceipt(client)

        let tokenInfoAfterWipeKeyUpdate = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(client)

        print("Wipe Key (after removal): \(String(describing: tokenInfoAfterWipeKeyUpdate.wipeKey))")
        print("------------------------------------")
        print("Removing Admin Key...")

        // Remove the admin key with empty Keylist, signing with the admin key.
        let _ = try await TokenUpdateTransaction()
            .tokenId(tokenId)
            .adminKey(.keyList([]))
            .keyVerificationMode(TokenKeyValidation.noValidation)
            .freezeWith(client)
            .sign(adminKey)
            .execute(client)
            .getReceipt(client)

        let tokenInfoAfterAdminKeyUpdate = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(client)

        print("Admin Key (after removal): \(String(describing:tokenInfoAfterAdminKeyUpdate.adminKey))")

        print("------------------------------------")
        print("Update Supply Key...")

        // Update the supply key with a new key, signing with the old supply key and the new supply key.
        let _ = try await TokenUpdateTransaction()
            .tokenId(tokenId)
            .supplyKey(.single(newSupplyKey.publicKey))
            .keyVerificationMode(TokenKeyValidation.fullValidation)
            .freezeWith(client)
            .sign(supplyKey)
            .sign(newSupplyKey)
            .execute(client)
            .getReceipt(client)

        let tokenInfoAfterSupplyKeyUpdate = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(client)

        print("Supply Key (after update): \(String(describing: tokenInfoAfterSupplyKeyUpdate.supplyKey))")

        print("------------------------------------")
        print("Removing Supply Key...")

        // Remove the supply key with unusable key, signing with the new supply key.
        let _ = try await TokenUpdateTransaction()
            .tokenId(tokenId)
            .supplyKey(.single(unusableKey))
            .keyVerificationMode(TokenKeyValidation.noValidation)
            .freezeWith(client)
            .sign(newSupplyKey)
            .execute(client)
            .getReceipt(client)

        let tokenInfoAfterSupplyKeyRemoval = try await TokenInfoQuery()
            .tokenId(tokenId)
            .execute(client)

        print("Supply Key (after removal): \(String(describing: tokenInfoAfterSupplyKeyRemoval.supplyKey))")
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

    /// The name of the hedera network this example should be ran against.
    ///
    /// Testnet by default.
    internal var networkName: String {
        self["HEDERA_NETWORK"]?.stringValue ?? "testnet"
    }
}
