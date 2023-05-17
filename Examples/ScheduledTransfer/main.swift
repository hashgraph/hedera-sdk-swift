/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
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

        // A scheduled transaction is a transaction that has been proposed by an account,
        // but which requires more signatures before it will actually execute on the Hedera network.
        //
        // For example, if Alice wants to transfer an amount of Hbar to Bob, and Bob has
        // receiverSignatureRequired set to true, then that transaction must be signed by
        // both Alice and Bob before the transaction will be executed.
        //
        // To solve this problem, Alice can propose the transaction by creating a scheduled
        // transaction on the Hedera network which, if executed, would transfer Hbar from
        // Alice to Bob.  That scheduled transaction will have a ScheduleId by which we can
        // refer to that scheduled transaction.  Alice can communicate the ScheduleId to Bob, and
        // then Bob can use a ScheduleSignTransaction to sign that scheduled transaction.
        //
        // Bob has a 30 minute window in which to sign the scheduled transaction, starting at the
        // moment that Alice creates the scheduled transaction.  If a scheduled transaction
        // is not signed by all of the necessary signatories within the 30 minute window,
        // that scheduled transaction will expire, and will not be executed.
        //
        // Once a scheduled transaction has all of the signatures necessary to execute, it will
        // be executed on the Hedera network automatically.  If you create a scheduled transaction
        // on the Hedera network, but that transaction only requires your signature in order to
        // execute and no one else's, that scheduled transaction will be automatically
        // executed immediately.
        let bobsKey = PrivateKey.generateEd25519()

        let bobsId = try await AccountCreateTransaction()
            .receiverSignatureRequired(true)
            .key(.single(bobsKey.publicKey))
            .initialBalance(10)
            .freezeWith(client)
            .sign(bobsKey)
            .execute(client)
            .getReceipt(client)
            .accountId!

        print(
            "Alice's ID: \(try env.operatorAccountId.toStringWithChecksum(client))"
        )

        print("Bob's ID: \(try bobsId.toStringWithChecksum(client))")

        let bobsInitialBalance = try await AccountBalanceQuery()
            .accountId(bobsId)
            .execute(client)

        print("Bob's initial balance:")
        print(bobsInitialBalance)

        let transferToSchedule = TransferTransaction()
            .hbarTransfer(env.operatorAccountId, -10)
            .hbarTransfer(bobsId, 10)

        print("Transfer to be scheduled:")
        print(transferToSchedule)

        // The `payerAccountId` is the account that will be charged the fee
        // for executing the scheduled transaction if/when it is executed.
        // That fee is separate from the fee that we will pay to execute the
        // ScheduleCreateTransaction itself.
        //
        // To clarify: Alice pays a fee to execute the ScheduleCreateTransaction,
        // which creates the scheduled transaction on the Hedera network.
        // She specifies when creating the scheduled transaction that Bob will pay
        // the fee for the scheduled transaction when it is executed.
        //
        // If `payerAccountId` is not specified, the account who creates the scheduled transaction
        // will be charged for executing the scheduled transaction.
        let scheduleId = try await ScheduleCreateTransaction()
            .scheduledTransaction(transferToSchedule)
            .payerAccountId(bobsId)
            .execute(client)
            .getReceipt(client)
            .scheduleId!

        print("The scheduleId is: \(scheduleId.toStringWithChecksum(client))")

        // Bob's balance should be unchanged.  The transfer has been scheduled, but it hasn't been executed yet
        // because it requires Bob's signature.
        let bobsBalanceAfterSchedule = try await AccountBalanceQuery()
            .accountId(bobsId)
            .execute(client)

        print("Bob's balance after scheduling the transfer (should be unchanged):")
        print(bobsBalanceAfterSchedule)

        // Once Alice has communicated the scheduleId to Bob, Bob can query for information about the
        // scheduled transaction.
        let scheduledTransactionInfo = try await ScheduleInfoQuery()
            .scheduleId(scheduleId)
            .execute(client)

        print("Info about scheduled transaction:")
        print(scheduledTransactionInfo)

        // getScheduledTransaction() will return an SDK Transaction object identical to the transaction
        // that was scheduled, which Bob can then inspect like a normal transaction.
        let scheduledTransaction = try scheduledTransactionInfo.scheduledTransaction

        // We happen to know that this transaction is (or certainly ought to be) a TransferTransaction
        let scheduledTransfer = scheduledTransaction as! TransferTransaction

        print("The scheduled transfer transaction from Bob's POV:")
        print(scheduledTransfer)

        _ = try await ScheduleSignTransaction()
            .scheduleId(scheduleId)
            .freezeWith(client)
            .sign(bobsKey)
            .execute(client)
            .getReceipt(client)

        let balanceAfterSigning = try await AccountBalanceQuery()
            .accountId(bobsId)
            .execute(client)

        print("Bob's balance after signing the scheduled transaction:")
        print("\(balanceAfterSigning)")

        let postTransactionInfo = try await ScheduleInfoQuery()
            .scheduleId(scheduleId)
            .execute(client)

        print("Info on the scheduled transaction, executedAt should no longer be null:")
        print("\(postTransactionInfo)")

        // Clean up
        _ = try await AccountDeleteTransaction()
            .transferAccountId(env.operatorAccountId)
            .accountId(bobsId)
            .freezeWith(client)
            .sign(bobsKey)
            .execute(client)
            .getReceipt(client)
    }
}

extension Environment {
    /// Account ID for the operator to use in this example.
    internal var operatorAccountId: AccountId {
        AccountId(self["OPERATOR_ACCOUNT_ID"]!.stringValue)!
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
