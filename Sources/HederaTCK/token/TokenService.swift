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
import HederaProtobufs
import NumberKit

@testable import Hedera

internal class TokenService {
    static let service = TokenService()

    ////////////////
    /// INTERNAL ///
    ///////////////

    internal func createToken(_ params: CreateTokenParams) async throws -> JSONObject {
        var tokenCreateTransaction = TokenCreateTransaction()

        if let name = params.name {
            tokenCreateTransaction.name = name
        }

        if let symbol = params.symbol {
            tokenCreateTransaction.symbol = symbol
        }

        if let decimals = params.decimals {
            tokenCreateTransaction.decimals = decimals
        }

        if let initialSupply = params.initialSupply {
            tokenCreateTransaction.initialSupply = toUint64(
                try toInt(initialSupply, "initialSupply", JSONRPCMethod.CREATE_TOKEN))
        }

        if let treasuryAccountId = params.treasuryAccountId {
            tokenCreateTransaction.treasuryAccountId = try AccountId.fromString(treasuryAccountId)
        }

        if let adminKey = params.adminKey {
            tokenCreateTransaction.adminKey = try KeyService.service.getHederaKey(adminKey)
        }

        if let kycKey = params.kycKey {
            tokenCreateTransaction.kycKey = try KeyService.service.getHederaKey(kycKey)
        }

        if let freezeKey = params.freezeKey {
            tokenCreateTransaction.freezeKey = try KeyService.service.getHederaKey(freezeKey)
        }

        if let wipeKey = params.wipeKey {
            tokenCreateTransaction.wipeKey = try KeyService.service.getHederaKey(wipeKey)
        }

        if let supplyKey = params.supplyKey {
            tokenCreateTransaction.supplyKey = try KeyService.service.getHederaKey(supplyKey)
        }

        if let freezeDefault = params.freezeDefault {
            tokenCreateTransaction.freezeDefault = freezeDefault
        }

        if let expirationTime = params.expirationTime {
            tokenCreateTransaction.expirationTime = Timestamp(
                seconds: toUint64(try toInt(expirationTime, "expirationTime", JSONRPCMethod.CREATE_TOKEN)),
                subSecondNanos: 0)
        }

        if let autoRenewAccountId = params.autoRenewAccountId {
            tokenCreateTransaction.autoRenewAccountId = try AccountId.fromString(autoRenewAccountId)
        }

        if let autoRenewPeriod = params.autoRenewPeriod {
            tokenCreateTransaction.autoRenewPeriod = Duration(
                seconds: toUint64(try toInt(autoRenewPeriod, "autoRenewPeriod", JSONRPCMethod.CREATE_TOKEN)))
        }

        if let memo = params.memo {
            tokenCreateTransaction.tokenMemo = memo
        }

        if let tokenType = params.tokenType {
            tokenCreateTransaction.tokenType =
                try ["ft", "nft"].contains(tokenType)
                ? (tokenType == "ft") ? .fungibleCommon : .nonFungibleUnique
                : { throw JSONError.invalidParams("\(#function): tokenType MUST be 'ft' or 'nft'.") }()
        }

        if let supplyType = params.supplyType {
            tokenCreateTransaction.tokenSupplyType =
                try ["finite", "infinite"].contains(supplyType)
                ? (supplyType == "finite" ? .finite : .infinite)
                : { throw JSONError.invalidParams("\(#function): supplyType MUST be 'finite' or 'infinite'.") }()
        }

        if let maxSupply = params.maxSupply {
            tokenCreateTransaction.maxSupply = toUint64(try toInt(maxSupply, "maxSupply", JSONRPCMethod.CREATE_TOKEN))
        }

        if let feeScheduleKey = params.feeScheduleKey {
            tokenCreateTransaction.feeScheduleKey = try KeyService.service.getHederaKey(feeScheduleKey)
        }

        if let customFees = params.customFees {
            tokenCreateTransaction.customFees.append(
                contentsOf: try customFees.map { try $0.toHederaCustomFee(JSONRPCMethod.CREATE_TOKEN) })
        }

        if let pauseKey = params.pauseKey {
            tokenCreateTransaction.pauseKey = try KeyService.service.getHederaKey(pauseKey)
        }

        if let metadata = params.metadata {
            tokenCreateTransaction.metadata =
                try metadata.data(using: .utf8)
                ?? { throw JSONError.invalidParams("\(#function): metadata MUST be a UTF-8 string.") }()
        }

        if let metadataKey = params.metadataKey {
            tokenCreateTransaction.metadataKey = try KeyService.service.getHederaKey(metadataKey)
        }

        if let commonTransactionParams = params.commonTransactionParams {
            try fillOutCommonTransactionParameters(
                transaction: &tokenCreateTransaction,
                params: commonTransactionParams,
                client: SDKClient.client.getClient()
            )
        }

        let txReceipt = try await tokenCreateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "tokenId": JSONObject.string(txReceipt.tokenId!.toString()),
            "status": JSONObject.string(txReceipt.status.description),
        ])
    }

    internal func deleteToken(_ params: DeleteTokenParams) async throws -> JSONObject {
        var tokenDeleteTransaction = TokenDeleteTransaction()

        if let tokenId = params.tokenId {
            tokenDeleteTransaction.tokenId = try TokenId.fromString(tokenId)
        }

        if let commonTransactionParams = params.commonTransactionParams {
            try fillOutCommonTransactionParameters(
                transaction: &tokenDeleteTransaction,
                params: commonTransactionParams,
                client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenDeleteTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "status": JSONObject.string(txReceipt.status.description)
        ])
    }

    internal func updateToken(_ params: UpdateTokenParams) async throws -> JSONObject {
        var tokenUpdateTransaction = try TokenUpdateTransaction(
            tokenId: params.tokenId.flatMap { try TokenId.fromString($0) },
            tokenName: params.name ?? "",
            tokenSymbol: params.symbol ?? "",
            treasuryAccountId: params.treasuryAccountId.flatMap { try AccountId.fromString($0) },
            adminKey: params.adminKey.flatMap { try KeyService.service.getHederaKey($0) },
            kycKey: params.kycKey.flatMap { try KeyService.service.getHederaKey($0) },
            freezeKey: params.freezeKey.flatMap { try KeyService.service.getHederaKey($0) },
            wipeKey: params.wipeKey.flatMap { try KeyService.service.getHederaKey($0) },
            supplyKey: params.supplyKey.flatMap { try KeyService.service.getHederaKey($0) },
            autoRenewAccountId: params.autoRenewAccountId.flatMap { try AccountId.fromString($0) },
            autoRenewPeriod: params.autoRenewPeriod.flatMap {
                Duration(seconds: toUint64(try toInt($0, "autoRenewPeriod", JSONRPCMethod.UPDATE_TOKEN)))
            },
            expirationTime: params.expirationTime.flatMap {
                Timestamp(
                    seconds: toUint64(try toInt($0, "expirationTime", JSONRPCMethod.UPDATE_TOKEN)), subSecondNanos: 0)
            },
            tokenMemo: params.memo,
            feeScheduleKey: params.feeScheduleKey.flatMap { try KeyService.service.getHederaKey($0) },
            pauseKey: params.pauseKey.flatMap { try KeyService.service.getHederaKey($0) },
            metadata: try params.metadata.flatMap {
                try $0.data(using: .utf8)
                    ?? { throw JSONError.invalidParams("\(#function): metadata MUST be a UTF-8 string.") }()
            },
            metadataKey: params.metadataKey.flatMap { try KeyService.service.getHederaKey($0) }
        )

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenUpdateTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenUpdateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "status": JSONObject.string(txReceipt.status.description)
        ])
    }
}
