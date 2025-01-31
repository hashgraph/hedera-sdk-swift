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

internal class AccountService {

    /// Singleton instance of AccountService.
    static let service = AccountService()

    /// Create an account. Can be called via JSON-RPC.
    internal func createAccount(_ params: CreateAccountParams) async throws -> JSONObject {
        var accountCreateTransaction = AccountCreateTransaction()

        accountCreateTransaction.key = try CommonParams.getKey(params.key)
        accountCreateTransaction.initialBalance =
            try params.initialBalance.flatMap {
                Hbar.fromTinybars(try toInt($0, "initialBalance", JSONRPCMethod.CREATE_ACCOUNT))
            } ?? accountCreateTransaction.initialBalance
        accountCreateTransaction.receiverSignatureRequired =
            params.receiverSignatureRequired ?? accountCreateTransaction.receiverSignatureRequired
        accountCreateTransaction.autoRenewPeriod = try CommonParams.getAutoRenewPeriod(
            params.autoRenewPeriod, JSONRPCMethod.CREATE_ACCOUNT)
        accountCreateTransaction.accountMemo = params.memo ?? accountCreateTransaction.accountMemo
        accountCreateTransaction.maxAutomaticTokenAssociations =
            params.maxAutoTokenAssociations ?? accountCreateTransaction.maxAutomaticTokenAssociations
        accountCreateTransaction.alias = try params.alias.flatMap { try EvmAddress.fromString($0) }
        accountCreateTransaction.stakedAccountId = try CommonParams.getAccountId(params.stakedAccountId)
        accountCreateTransaction.stakedNodeId = try CommonParams.getStakedNodeId(
            params.stakedNodeId, JSONRPCMethod.CREATE_ACCOUNT)
        accountCreateTransaction.declineStakingReward =
            params.declineStakingReward ?? accountCreateTransaction.declineStakingReward
        try params.commonTransactionParams?.fillOutTransaction(&accountCreateTransaction)

        let txReceipt = try await accountCreateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "accountId": JSONObject.string(txReceipt.accountId!.toString()),
            "status": JSONObject.string(txReceipt.status.description),
        ])
    }

    /// Delete an account. Can be called via JSON-RPC.
    internal func deleteAccount(_ params: DeleteAccountParams) async throws -> JSONObject {
        var accountDeleteTransaction = AccountDeleteTransaction()

        accountDeleteTransaction.accountId = try CommonParams.getAccountId(params.deleteAccountId)
        accountDeleteTransaction.transferAccountId = try CommonParams.getAccountId(params.transferAccountId)
        try params.commonTransactionParams?.fillOutTransaction(&accountDeleteTransaction)

        let txReceipt = try await accountDeleteTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    /// Update an account. Can be called via JSON-RPC.
    internal func updateAccount(_ params: UpdateAccountParams) async throws -> JSONObject {
        var accountUpdateTransaction = AccountUpdateTransaction()

        accountUpdateTransaction.accountId = try CommonParams.getAccountId(params.accountId)
        accountUpdateTransaction.key = try CommonParams.getKey(params.key)
        accountUpdateTransaction.autoRenewPeriod = try CommonParams.getAutoRenewPeriod(
            params.autoRenewPeriod, JSONRPCMethod.UPDATE_ACCOUNT)
        accountUpdateTransaction.expirationTime = try CommonParams.getExpirationTime(
            params.expirationTime, JSONRPCMethod.UPDATE_ACCOUNT)
        accountUpdateTransaction.receiverSignatureRequired = params.receiverSignatureRequired
        accountUpdateTransaction.accountMemo = params.memo
        accountUpdateTransaction.maxAutomaticTokenAssociations = params.maxAutoTokenAssociations
        accountUpdateTransaction.stakedAccountId = try CommonParams.getAccountId(params.stakedAccountId)
        accountUpdateTransaction.stakedNodeId = try CommonParams.getStakedNodeId(
            params.stakedNodeId, JSONRPCMethod.UPDATE_ACCOUNT)
        accountUpdateTransaction.declineStakingReward = params.declineStakingReward
        try params.commonTransactionParams?.fillOutTransaction(&accountUpdateTransaction)

        let txReceipt = try await accountUpdateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }
}
