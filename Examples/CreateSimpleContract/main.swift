// SPDX-License-Identifier: Apache-2.0

import Hedera
import HederaExampleUtilities
import SwiftDotenv

@main
internal enum Program {
    internal static func main() async throws {
        let env = try Dotenv.load()
        let client = try Client.forName(env.networkName)

        client.setOperator(env.operatorAccountId, env.operatorKey)

        let bytecode = try await HederaExampleUtilities.Resources.simpleContract

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
            .adminKey(.single(env.operatorKey.publicKey))
            .constructorParameters(ContractFunctionParameters().addString("hello from hedera!"))
            .execute(client)

        let contractReceipt = try await contractTransactionResponse.getReceipt(client)
        let newContractId = contractReceipt.contractId!

        print("new contract ID: \(newContractId)")

        let contractCallResult = try await ContractCallQuery()
            .contractId(newContractId)
            .gas(500000)
            .function("greet")
            .execute(client)

        if let err = contractCallResult.errorMessage {
            print("error calling contract: \(err)")
            return
        }

        let message = contractCallResult.getString(0)
        print("contract returned message: \(String(describing: message))")

        // now delete the contract
        _ = try await ContractDeleteTransaction()
            .contractId(newContractId)
            .transferAccountId(env.operatorAccountId)
            .execute(client)
            .getReceipt(client)

        print("Contract successfully deleted")
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
