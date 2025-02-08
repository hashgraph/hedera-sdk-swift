/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2025 Hiero LLC
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

import Hiero
import HieroExampleUtilities
import SwiftDotenv

@main
internal enum Program {
    internal static func main() async throws {
        let env = try Dotenv.load()
        let client = try Client.forName(env.networkName)

        client.setOperator(env.operatorAccountId, env.operatorKey)

        let bytecode = try await HieroExampleUtilities.Resources.statefulContract

        // create the contract's bytecode file
        let fileTransactionResponse = try await FileCreateTransaction()
            // Use the same key as the operator to "own" this file
            .keys([.single(env.operatorKey.publicKey)])
            .contents(bytecode.data(using: .utf8)!)
            .execute(client)

        let fileReceipt = try await fileTransactionResponse.getReceipt(client)
        let newFileId = fileReceipt.fileId!

        print("contract bytecode file: \(newFileId)")

        let contractTransactionResponse = try await ContractCreateTransaction()
            .bytecodeFileId(newFileId)
            .gas(500000)
            .constructorParameters(ContractFunctionParameters().addString("hello from hedera!"))
            .execute(client)

        let contractReceipt = try await contractTransactionResponse.getReceipt(client)
        let newContractId = contractReceipt.contractId!

        print("new contract ID: \(newContractId)")

        let contractCallResult = try await ContractCallQuery()
            .contractId(newContractId)
            .gas(500000)
            .function("get_message")
            .execute(client)

        if let err = contractCallResult.errorMessage {
            print("error calling contract: \(err)")
            return
        }

        let message = contractCallResult.getString(0)
        print("contract returned message: \(String(describing: message))")

        let contractExecTransactionResponse = try await ContractExecuteTransaction()
            .contractId(newContractId)
            .gas(500000)
            .function(
                "set_message",
                ContractFunctionParameters().addString("hello from hedera again!")
            )
            .execute(client)

        // if this doesn't throw then we know the contract executed successfully
        _ = try await contractExecTransactionResponse.getReceipt(client)

        // now query contract
        let contractUpdateResult = try await ContractCallQuery()
            .contractId(newContractId)
            .gas(500000)
            .function("get_message")
            .execute(client)

        if let err = contractUpdateResult.errorMessage {
            print("error calling contract: \(err)")
            return
        }

        let message2 = contractUpdateResult.getString(0)
        print("contract returned message: \(String(describing: message2))")
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
