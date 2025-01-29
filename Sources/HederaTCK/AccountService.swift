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

    internal func createAccount(_ parameters: [String: JSONObject]?) async throws -> JSONObject {
        var accountCreateTransaction = AccountCreateTransaction()

        if let params = parameters {
            if let key: String = try getOptionalJsonParameter("key", params, #function) {
                accountCreateTransaction.key = try KeyService.service.getHederaKey(key)
            }

            if let initialBalance: String = try getOptionalJsonParameter(
                "initialBalance", params, #function)
            {
                accountCreateTransaction.initialBalance = Hbar.fromTinybars(
                    try toInt(initialBalance, "initialBalance", #function))
            }

            if let receiverSignatureRequired: Bool = try getOptionalJsonParameter(
                "receiverSignatureRequired", params, #function)
            {
                accountCreateTransaction.receiverSignatureRequired = receiverSignatureRequired
            }

            if let autoRenewPeriod: String = try getOptionalJsonParameter(
                "autoRenewPeriod", params, #function)
            {
                accountCreateTransaction.autoRenewPeriod = Duration(
                    seconds: toUint64(try toInt(autoRenewPeriod, "autoRenewPeriod", #function)))
            }

            if let memo: String = try getOptionalJsonParameter("memo", params, #function) {
                accountCreateTransaction.accountMemo = memo
            }

            if let maxAutoTokenAssociations: Int32 = try getOptionalJsonParameter(
                "maxAutoTokenAssociations", params, #function)
            {
                accountCreateTransaction.maxAutomaticTokenAssociations = maxAutoTokenAssociations
            }

            if let stakedAccountId: String = try getOptionalJsonParameter(
                "stakedAccountId", params, #function)
            {
                accountCreateTransaction.stakedAccountId = try AccountId.fromString(stakedAccountId)
            }

            if let stakedNodeId: String = try getOptionalJsonParameter(
                "stakedNodeId", params, #function)
            {
                accountCreateTransaction.stakedNodeId = toUint64(try toInt(stakedNodeId, "stakedNodeId", #function))
            }

            if let declineStakingReward: Bool = try getOptionalJsonParameter(
                "declineStakingReward", params, #function)
            {
                accountCreateTransaction.declineStakingReward = declineStakingReward
            }

            if let alias: String = try getOptionalJsonParameter("alias", params, #function) {
                accountCreateTransaction.alias = try EvmAddress.fromString(alias)
            }

            if let commonTransactionParams: [String: JSONObject] = try getOptionalJsonParameter(
                "commonTransactionParams", params, #function)
            {
                try fillOutCommonTransactionParameters(
                    &accountCreateTransaction, params: commonTransactionParams, client: SDKClient.client.getClient(),
                    function: #function
                )
            }
        }

        let txReceipt = try await accountCreateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "accountId": JSONObject.string(txReceipt.accountId!.toString()),
            "status": JSONObject.string(txReceipt.status.description),
        ])
    }

    internal func deleteAccount(_ parameters: [String: JSONObject]?) async throws -> JSONObject {
        var accountDeleteTransaction = AccountDeleteTransaction()

        if let params = parameters {
            if let deleteAccountId: String = try getOptionalJsonParameter("deleteAccountId", params, #function) {
                accountDeleteTransaction.accountId = try AccountId.fromString(deleteAccountId)
            }

            if let transferAccountId: String = try getOptionalJsonParameter("transferAccountId", params, #function) {
                accountDeleteTransaction.transferAccountId = try AccountId.fromString(transferAccountId)
            }

            if let commonTransactionParams: [String: JSONObject] = try getOptionalJsonParameter(
                "commonTransactionParams", params, #function)
            {
                try fillOutCommonTransactionParameters(
                    &accountDeleteTransaction, params: commonTransactionParams, client: SDKClient.client.getClient(),
                    function: #function
                )
            }
        }

        let txReceipt = try await accountDeleteTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "status": JSONObject.string(txReceipt.status.description)
        ])
    }

    internal func updateAccount(_ parameters: [String: JSONObject]?) async throws -> JSONObject {
        var accountUpdateTransaction = AccountUpdateTransaction()

        if let params = parameters {
            if let accountId: String = try getOptionalJsonParameter("accountId", params, #function) {
                accountUpdateTransaction.accountId = try AccountId.fromString(accountId)
            }

            if let key: String = try getOptionalJsonParameter("key", params, #function) {
                accountUpdateTransaction.key = try KeyService.service.getHederaKey(key)
            }

            if let autoRenewPeriod: String = try getOptionalJsonParameter(
                "autoRenewPeriod", params, #function)
            {
                accountUpdateTransaction.autoRenewPeriod = Duration(
                    seconds: toUint64(try toInt(autoRenewPeriod, "autoRenewPeriod", #function)))
            }

            if let expirationTime: String = try getOptionalJsonParameter("expirationTime", params, #function) {
                accountUpdateTransaction.expirationTime = Timestamp(
                    seconds: toUint64(try toInt(expirationTime, "expirationTime", #function)), subSecondNanos: 0)
            }

            if let receiverSignatureRequired: Bool = try getOptionalJsonParameter(
                "receiverSignatureRequired", params, #function)
            {
                accountUpdateTransaction.receiverSignatureRequired = receiverSignatureRequired
            }

            if let memo: String = try getOptionalJsonParameter("memo", params, #function) {
                accountUpdateTransaction.accountMemo = memo
            }

            if let maxAutoTokenAssociations: Int32 = try getOptionalJsonParameter(
                "maxAutoTokenAssociations", params, #function)
            {
                accountUpdateTransaction.maxAutomaticTokenAssociations = maxAutoTokenAssociations
            }

            if let stakedAccountId: String = try getOptionalJsonParameter(
                "stakedAccountId", params, #function)
            {
                accountUpdateTransaction.stakedAccountId = try AccountId.fromString(stakedAccountId)
            }

            if let stakedNodeId: String = try getOptionalJsonParameter(
                "stakedNodeId", params, #function)
            {
                accountUpdateTransaction.stakedNodeId = toUint64(try toInt(stakedNodeId, "stakedNodeId", #function))
            }

            if let declineStakingReward: Bool = try getOptionalJsonParameter(
                "declineStakingReward", params, #function)
            {
                accountUpdateTransaction.declineStakingReward = declineStakingReward
            }

            if let commonTransactionParams: [String: JSONObject] = try getOptionalJsonParameter(
                "commonTransactionParams", params, #function)
            {
                try fillOutCommonTransactionParameters(
                    &accountUpdateTransaction, params: commonTransactionParams, client: SDKClient.client.getClient(),
                    function: #function
                )
            }
        }

        let txReceipt = try await accountUpdateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "status": JSONObject.string(txReceipt.status.description)
        ])
    }
}
