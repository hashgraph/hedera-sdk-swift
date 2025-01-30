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
    ////////////////

    internal func associateToken(_ params: AssociateTokenParams) async throws -> JSONObject {
        var tokenAssociateTransaction = TokenAssociateTransaction()

        tokenAssociateTransaction.accountId = try params.accountId.flatMap { try AccountId.fromString($0) }
        tokenAssociateTransaction.tokenIds = try params.tokenIds?.map { try TokenId.fromString($0) } ?? []

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenAssociateTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenAssociateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func createToken(_ params: CreateTokenParams) async throws -> JSONObject {
        var tokenCreateTransaction = TokenCreateTransaction()

        tokenCreateTransaction.name = params.name ?? tokenCreateTransaction.name
        tokenCreateTransaction.symbol = params.symbol ?? tokenCreateTransaction.symbol
        tokenCreateTransaction.decimals = params.decimals ?? tokenCreateTransaction.decimals
        tokenCreateTransaction.initialSupply =
            try params.initialSupply.flatMap { toUint64(try toInt($0, "initialSupply", JSONRPCMethod.CREATE_TOKEN)) }
            ?? tokenCreateTransaction.initialSupply
        tokenCreateTransaction.treasuryAccountId = try params.treasuryAccountId.flatMap { try AccountId.fromString($0) }
        tokenCreateTransaction.adminKey = try params.adminKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenCreateTransaction.kycKey = try params.kycKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenCreateTransaction.freezeKey = try params.freezeKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenCreateTransaction.wipeKey = try params.wipeKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenCreateTransaction.supplyKey = try params.supplyKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenCreateTransaction.freezeDefault = params.freezeDefault ?? tokenCreateTransaction.freezeDefault
        tokenCreateTransaction.expirationTime = try params.expirationTime.flatMap {
            Timestamp(seconds: toUint64(try toInt($0, "expirationTime", JSONRPCMethod.CREATE_TOKEN)), subSecondNanos: 0)
        }
        tokenCreateTransaction.autoRenewAccountId = try params.autoRenewAccountId.flatMap {
            try AccountId.fromString($0)
        }
        tokenCreateTransaction.autoRenewPeriod = try params.autoRenewPeriod.flatMap {
            Duration(seconds: toUint64(try toInt($0, "autoRenewPeriod", JSONRPCMethod.CREATE_TOKEN)))
        }
        tokenCreateTransaction.tokenMemo = params.memo ?? tokenCreateTransaction.tokenMemo
        tokenCreateTransaction.tokenType =
            try params.tokenType.flatMap {
                try ["ft", "nft"].contains($0)
                    ? ($0 == "ft" ? .fungibleCommon : .nonFungibleUnique)
                    : { throw JSONError.invalidParams("\(#function): tokenType MUST be 'ft' or 'nft'.") }()
            } ?? tokenCreateTransaction.tokenType
        tokenCreateTransaction.tokenSupplyType =
            try params.supplyType.flatMap {
                try ["finite", "infinite"].contains($0)
                    ? ($0 == "finite" ? .finite : .infinite)
                    : { throw JSONError.invalidParams("\(#function): supplyType MUST be 'finite' or 'infinite'.") }()
            } ?? tokenCreateTransaction.tokenSupplyType
        tokenCreateTransaction.maxSupply =
            try params.maxSupply.flatMap { toUint64(try toInt($0, "maxSupply", JSONRPCMethod.CREATE_TOKEN)) }
            ?? tokenCreateTransaction.maxSupply
        tokenCreateTransaction.feeScheduleKey = try params.feeScheduleKey.flatMap {
            try KeyService.service.getHederaKey($0)
        }
        tokenCreateTransaction.customFees =
            try params.customFees?.map { try $0.toHederaCustomFee(JSONRPCMethod.CREATE_TOKEN) } ?? []
        tokenCreateTransaction.pauseKey = try params.pauseKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenCreateTransaction.metadata =
            try params.metadata.flatMap {
                try $0.data(using: .utf8)
                    ?? { throw JSONError.invalidParams("\(#function): metadata MUST be a UTF-8 string.") }()
            } ?? tokenCreateTransaction.metadata
        tokenCreateTransaction.metadataKey = try params.metadataKey.flatMap {
            try KeyService.service.getHederaKey($0)
        }

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenCreateTransaction, params: $0, client: SDKClient.client.getClient())
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

        tokenDeleteTransaction.tokenId = try params.tokenId.flatMap { try TokenId.fromString($0) }

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenDeleteTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenDeleteTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func dissociateToken(_ params: DissociateTokenParams) async throws -> JSONObject {
        var tokenDissociateTransaction = TokenDissociateTransaction()

        tokenDissociateTransaction.accountId = try params.accountId.flatMap { try AccountId.fromString($0) }
        tokenDissociateTransaction.tokenIds = try params.tokenIds?.map { try TokenId.fromString($0) } ?? []

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenDissociateTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenDissociateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func freezeToken(_ params: FreezeTokenParams) async throws -> JSONObject {
        var tokenFreezeTransaction = TokenFreezeTransaction()

        tokenFreezeTransaction.accountId = try params.accountId.flatMap { try AccountId.fromString($0) }
        tokenFreezeTransaction.tokenId = try params.tokenId.flatMap { try TokenId.fromString($0) }

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenFreezeTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenFreezeTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func pauseToken(_ params: PauseTokenParams) async throws -> JSONObject {
        var tokenPauseTransaction = TokenPauseTransaction()

        tokenPauseTransaction.tokenId = try params.tokenId.flatMap { try TokenId.fromString($0) }

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenPauseTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenPauseTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func unpauseToken(_ params: UnpauseTokenParams) async throws -> JSONObject {
        var tokenUnpauseTransaction = TokenUnpauseTransaction()

        tokenUnpauseTransaction.tokenId = try params.tokenId.flatMap { try TokenId.fromString($0) }

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenUnpauseTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenUnpauseTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func updateTokenFeeSchedule(_ params: UpdateTokenFeeScheduleParams) async throws -> JSONObject {
        var tokenFeeScheduleUpdateTransaction = TokenFeeScheduleUpdateTransaction()

        tokenFeeScheduleUpdateTransaction.tokenId = try params.tokenId.flatMap { try TokenId.fromString($0) }
        tokenFeeScheduleUpdateTransaction.customFees =
            try params.customFees?.map { try $0.toHederaCustomFee(JSONRPCMethod.UPDATE_TOKEN_FEE_SCHEDULE) } ?? []

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenFeeScheduleUpdateTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenFeeScheduleUpdateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }

    internal func updateToken(_ params: UpdateTokenParams) async throws -> JSONObject {
        var tokenUpdateTransaction = TokenUpdateTransaction()

        tokenUpdateTransaction.tokenId = try params.tokenId.flatMap { try TokenId.fromString($0) }
        tokenUpdateTransaction.tokenName = params.name ?? tokenUpdateTransaction.tokenName
        tokenUpdateTransaction.tokenSymbol = params.symbol ?? tokenUpdateTransaction.tokenSymbol
        tokenUpdateTransaction.treasuryAccountId = try params.treasuryAccountId.flatMap { try AccountId.fromString($0) }
        tokenUpdateTransaction.adminKey = try params.adminKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenUpdateTransaction.kycKey = try params.kycKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenUpdateTransaction.freezeKey = try params.freezeKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenUpdateTransaction.wipeKey = try params.wipeKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenUpdateTransaction.supplyKey = try params.supplyKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenUpdateTransaction.autoRenewAccountId = try params.autoRenewAccountId.flatMap {
            try AccountId.fromString($0)
        }
        tokenUpdateTransaction.autoRenewPeriod = try params.autoRenewPeriod.flatMap {
            Duration(seconds: toUint64(try toInt($0, "autoRenewPeriod", JSONRPCMethod.UPDATE_TOKEN)))
        }
        tokenUpdateTransaction.expirationTime = try params.expirationTime.flatMap {
            Timestamp(seconds: toUint64(try toInt($0, "expirationTime", JSONRPCMethod.UPDATE_TOKEN)), subSecondNanos: 0)
        }
        tokenUpdateTransaction.tokenMemo = params.memo
        tokenUpdateTransaction.feeScheduleKey = try params.feeScheduleKey.flatMap {
            try KeyService.service.getHederaKey($0)
        }
        tokenUpdateTransaction.pauseKey = try params.pauseKey.flatMap { try KeyService.service.getHederaKey($0) }
        tokenUpdateTransaction.metadata = try params.metadata.flatMap {
            try $0.data(using: .utf8)
                ?? { throw JSONError.invalidParams("\(#function): metadata MUST be a UTF-8 string.") }()
        }
        tokenUpdateTransaction.metadataKey = try params.metadataKey.flatMap { try KeyService.service.getHederaKey($0) }

        try params.commonTransactionParams.map {
            try fillOutCommonTransactionParameters(
                transaction: &tokenUpdateTransaction, params: $0, client: SDKClient.client.getClient())
        }

        let txReceipt = try await tokenUpdateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary(["status": JSONObject.string(txReceipt.status.description)])
    }
}
