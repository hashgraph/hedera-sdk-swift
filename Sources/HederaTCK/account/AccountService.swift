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
import Foundation
import Hedera

internal class AccountService {
    static let service = AccountService()

    internal func createAccount(_ params: CreateAccountParams) async throws -> JSONObject {
        var accountCreateTransaction = AccountCreateTransaction()

        if let key = params.key {
            accountCreateTransaction.key = try KeyService.service.getHederaKey(key)
        }

        if let initialBalance = params.initialBalance {
            accountCreateTransaction.initialBalance = Hbar.fromTinybars(
                try toInt(initialBalance, "initialBalance", JSONRPCMethod.CREATE_ACCOUNT))
        }

        if let receiverSignatureRequired = params.receiverSignatureRequired {
            accountCreateTransaction.receiverSignatureRequired = receiverSignatureRequired
        }

        if let autoRenewPeriod = params.autoRenewPeriod {
            accountCreateTransaction.autoRenewPeriod = Duration(
                seconds: toUint64(try toInt(autoRenewPeriod, "autoRenewPeriod", JSONRPCMethod.CREATE_ACCOUNT)))
        }

        if let memo = params.memo {
            accountCreateTransaction.accountMemo = memo
        }

        if let maxAutoTokenAssociations = params.maxAutoTokenAssociations {
            accountCreateTransaction.maxAutomaticTokenAssociations = maxAutoTokenAssociations
        }

        if let stakedAccountId = params.stakedAccountId {
            accountCreateTransaction.stakedAccountId = try AccountId.fromString(stakedAccountId)
        }

        if let stakedNodeId = params.stakedNodeId {
            accountCreateTransaction.stakedNodeId = toUint64(
                try toInt(stakedNodeId, "stakedNodeId", JSONRPCMethod.CREATE_ACCOUNT))
        }

        if let declineStakingReward = params.declineStakingReward {
            accountCreateTransaction.declineStakingReward = declineStakingReward
        }

        if let alias = params.alias {
            accountCreateTransaction.alias = try EvmAddress.fromString(alias)
        }

        if let commonTransactionParams = params.commonTransactionParams {
            try fillOutCommonTransactionParameters(
                transaction: &accountCreateTransaction,
                params: commonTransactionParams,
                client: SDKClient.client.getClient()
            )
        }

        let txReceipt = try await accountCreateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "accountId": JSONObject.string(txReceipt.accountId!.toString()),
            "status": JSONObject.string(txReceipt.status.description),
        ])
    }

    internal func deleteAccount(_ params: DeleteAccountParams) async throws -> JSONObject {
        var accountDeleteTransaction = AccountDeleteTransaction()

        if let deleteAccountId = params.deleteAccountId {
            accountDeleteTransaction.accountId = try AccountId.fromString(deleteAccountId)
        }

        if let transferAccountId = params.transferAccountId {
            accountDeleteTransaction.transferAccountId = try AccountId.fromString(transferAccountId)
        }

        if let commonTransactionParams = params.commonTransactionParams {
            try fillOutCommonTransactionParameters(
                transaction: &accountDeleteTransaction,
                params: commonTransactionParams,
                client: SDKClient.client.getClient()
            )
        }

        let txReceipt = try await accountDeleteTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "status": JSONObject.string(txReceipt.status.description)
        ])
    }

    internal func updateAccount(_ params: UpdateAccountParams) async throws -> JSONObject {
        var accountUpdateTransaction = AccountUpdateTransaction()

        if let accountId = params.accountId {
            accountUpdateTransaction.accountId = try AccountId.fromString(accountId)
        }

        if let key = params.key {
            accountUpdateTransaction.key = try KeyService.service.getHederaKey(key)
        }

        if let autoRenewPeriod = params.autoRenewPeriod {
            accountUpdateTransaction.autoRenewPeriod = Duration(
                seconds: toUint64(try toInt(autoRenewPeriod, "autoRenewPeriod", JSONRPCMethod.UPDATE_ACCOUNT)))
        }

        if let expirationTime = params.expirationTime {
            accountUpdateTransaction.expirationTime = Timestamp(
                seconds: toUint64(try toInt(expirationTime, "expirationTime", JSONRPCMethod.UPDATE_ACCOUNT)),
                subSecondNanos: 0)
        }

        if let receiverSignatureRequired = params.receiverSignatureRequired {
            accountUpdateTransaction.receiverSignatureRequired = receiverSignatureRequired
        }

        if let memo = params.memo {
            accountUpdateTransaction.accountMemo = memo
        }

        if let maxAutoTokenAssociations = params.maxAutoTokenAssociations {
            accountUpdateTransaction.maxAutomaticTokenAssociations = maxAutoTokenAssociations
        }

        if let stakedAccountId = params.stakedAccountId {
            accountUpdateTransaction.stakedAccountId = try AccountId.fromString(stakedAccountId)
        }

        if let stakedNodeId = params.stakedNodeId {
            accountUpdateTransaction.stakedNodeId = toUint64(
                try toInt(stakedNodeId, "stakedNodeId", JSONRPCMethod.UPDATE_ACCOUNT))
        }

        if let declineStakingReward = params.declineStakingReward {
            accountUpdateTransaction.declineStakingReward = declineStakingReward
        }

        if let commonTransactionParams = params.commonTransactionParams {
            try fillOutCommonTransactionParameters(
                transaction: &accountUpdateTransaction,
                params: commonTransactionParams,
                client: SDKClient.client.getClient()
            )
        }

        let txReceipt = try await accountUpdateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "status": JSONObject.string(txReceipt.status.description)
        ])
    }
}
