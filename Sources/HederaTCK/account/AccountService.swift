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

        accountCreateTransaction.key = try params.key.flatMap { try KeyService.service.getHederaKey($0) }
        accountCreateTransaction.initialBalance =
            try params.initialBalance.flatMap {
                Hbar.fromTinybars(try toInt($0, "initialBalance", JSONRPCMethod.CREATE_ACCOUNT))
            } ?? accountCreateTransaction.initialBalance
        accountCreateTransaction.receiverSignatureRequired =
            params.receiverSignatureRequired ?? accountCreateTransaction.receiverSignatureRequired
        accountCreateTransaction.autoRenewPeriod = try params.autoRenewPeriod.flatMap {
            Duration(seconds: toUint64(try toInt($0, "autoRenewPeriod", JSONRPCMethod.CREATE_ACCOUNT)))
        }
        accountCreateTransaction.accountMemo = params.memo ?? accountCreateTransaction.accountMemo
        accountCreateTransaction.maxAutomaticTokenAssociations =
            params.maxAutoTokenAssociations ?? accountCreateTransaction.maxAutomaticTokenAssociations
        accountCreateTransaction.alias = try params.alias.flatMap { try EvmAddress.fromString($0) }
        accountCreateTransaction.stakedAccountId = try params.stakedAccountId.flatMap { try AccountId.fromString($0) }
        accountCreateTransaction.stakedNodeId = try params.stakedNodeId.flatMap {
            toUint64(try toInt($0, "stakedNodeId", JSONRPCMethod.CREATE_ACCOUNT))
        }
        accountCreateTransaction.declineStakingReward =
            params.declineStakingReward ?? accountCreateTransaction.declineStakingReward

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &accountCreateTransaction, params: $0, client: SDKClient.client.getClient())
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

        accountDeleteTransaction.accountId = try params.deleteAccountId.flatMap { try AccountId.fromString($0) }
        accountDeleteTransaction.transferAccountId = try params.transferAccountId.flatMap {
            try AccountId.fromString($0)
        }

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &accountDeleteTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await accountDeleteTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func updateAccount(_ params: UpdateAccountParams) async throws -> JSONObject {
        var accountUpdateTransaction = AccountUpdateTransaction()

        accountUpdateTransaction.accountId = try params.accountId.flatMap { try AccountId.fromString($0) }
        accountUpdateTransaction.key = try params.key.flatMap { try KeyService.service.getHederaKey($0) }
        accountUpdateTransaction.autoRenewPeriod = try params.autoRenewPeriod.flatMap {
            Duration(seconds: toUint64(try toInt($0, "autoRenewPeriod", JSONRPCMethod.UPDATE_ACCOUNT)))
        }
        accountUpdateTransaction.expirationTime = try params.expirationTime.flatMap {
            Timestamp(
                seconds: toUint64(try toInt($0, "expirationTime", JSONRPCMethod.UPDATE_ACCOUNT)), subSecondNanos: 0)
        }
        accountUpdateTransaction.receiverSignatureRequired = params.receiverSignatureRequired
        accountUpdateTransaction.accountMemo = params.memo
        accountUpdateTransaction.maxAutomaticTokenAssociations = params.maxAutoTokenAssociations
        accountUpdateTransaction.stakedAccountId = try params.stakedAccountId.flatMap { try AccountId.fromString($0) }
        accountUpdateTransaction.stakedNodeId = try params.stakedNodeId.flatMap {
            toUint64(try toInt($0, "stakedNodeId", JSONRPCMethod.UPDATE_ACCOUNT))
        }
        accountUpdateTransaction.declineStakingReward = params.declineStakingReward

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &accountUpdateTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await accountUpdateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }
}
