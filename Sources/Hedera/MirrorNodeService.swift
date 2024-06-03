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

import AsyncHTTPClient
import Foundation
import HederaProtobufs

internal final class MirrorNodeService {
    internal var mirrorNodeGateway: MirrorNodeGateway

    init(_ mirrorNodeGateway: MirrorNodeGateway) {
        self.mirrorNodeGateway = mirrorNodeGateway
    }

    internal func getAccountNum(_ evmAddress: String) async throws -> UInt64 {
        let accountInfoResponse = try await self.mirrorNodeGateway.getAccountInfo(evmAddress)

        guard let accountId = accountInfoResponse["account"] else {
            throw NSError(
                domain: "InvalidResponseError", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Error while processing getAccountInfo mirror node query"])
        }

        let accountNum = AccountId(String(describing: accountId))?.num

        return accountNum!
    }

    internal func getAccountEvmAddress(_ num: UInt64) async throws -> EvmAddress {
        let accountInfoResponse = try await self.mirrorNodeGateway.getAccountInfo(String(describing: num))

        guard let addressAny = accountInfoResponse["evm_address"] else {
            fatalError("Error while processing getAccountEvmAddress mirror node query")
        }

        let evmAddress = AccountId(String(describing: addressAny))?.evmAddress

        return evmAddress!
    }

    internal func getContractNum(_ evmAddress: String) async throws -> UInt64 {
        let contractInfoResponse = try await self.mirrorNodeGateway.getContractInfo(evmAddress)

        guard let contractId = contractInfoResponse["contract_id"] else {
            throw NSError(
                domain: "InvalidResponseError", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Error while processing getContractNum mirror node query"
                ])
        }

        let contractIdNum = ContractId(String(describing: contractId))?.num

        return contractIdNum!
    }

    internal func getTokenBalancesForAccount(_ evmAddress: String) async throws -> [Proto_TokenBalance] {
        let accountTokensResponse = try await self.mirrorNodeGateway.getAccountTokens(evmAddress)

        guard let tokens = accountTokensResponse["tokens"] else {
            throw NSError(
                domain: "InvalidResponseError", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Error while processing getAccountTokens mirror node query"
                ])
        }

        var tokenBalances: [Proto_TokenBalance] = []

        guard let tokensList: [[String: Any]] = tokens as? [[String: Any]] else {
            throw NSError(
                domain: "InvalidResponseError", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Error while processing getTokenBalancesForAccount mirror node query"
                ])
        }
        tokensList.forEach { token in
            var tokenId: String = ""
            var balance: UInt64 = 0
            var decimals: UInt32 = 0

            if let id = token["token_id"] as? String {
                tokenId = id
            }

            if let hbar = token["balance"] as? String {
                balance = UInt64(hbar)!
            }

            if let dec = token["decimals"] as? String {
                decimals = UInt32(dec)!
            }

            let tokenBalanceProto = Proto_TokenBalance.with { proto in
                proto.tokenID = TokenId(tokenId)!.toProtobuf()
                proto.balance = balance
                proto.decimals = decimals
            }

            tokenBalances.append(tokenBalanceProto)
        }

        return tokenBalances
    }

    internal func getTokenRelationshipsForAccount(_ evmAddress: String) async throws -> [Proto_TokenRelationship] {
        let accountTokensResponse = try await self.mirrorNodeGateway.getAccountTokens(evmAddress)

        guard let tokens = accountTokensResponse["tokens"] else {
            throw NSError(
                domain: "InvalidResponseError", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Error while processing getTokenRelationshipsForAccount mirror node query"
                ])
        }

        var tokenBalances: [Proto_TokenRelationship] = []

        guard let tokensList: [[String: Any]] = tokens as? [[String: Any]] else {
            throw NSError(
                domain: "InvalidResponseError", code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Error while processing getTokenBalancesForAccount mirror node query"
                ])
        }
        try tokensList.forEach { token in
            var tokenId: String = ""
            var balance: UInt64 = 0
            var decimals: UInt32 = 0
            var kycStatus: String = ""
            var freezeStatus: String = ""
            var automaticAssociation: Bool = false
            if let id = token["token_id"] as? String {
                tokenId = id
            }

            if let hbar = token["balance"] as? String {
                balance = UInt64(hbar)!
            }

            if let dec = token["decimals"] as? String {
                decimals = UInt32(dec)!
            }

            if let kyc = token["kyc_status"] as? String {
                kycStatus = kyc
            }

            if let freeze = token["freeze_status"] as? String {
                freezeStatus = freeze
            }

            if let auto = token["automatic_association"] as? String {
                automaticAssociation = Bool(auto)!
            }

            let tokenRelationshipsProto = try Proto_TokenRelationship.with { proto in
                proto.tokenID = TokenId(tokenId)!.toProtobuf()
                proto.balance = balance
                proto.decimals = decimals
                proto.kycStatus = try getTokenKycStatusFromString(kycStatus)
                proto.freezeStatus = try getTokenFreezeStatusFromString(freezeStatus)
                proto.automaticAssociation = automaticAssociation
            }

            tokenBalances.append(tokenRelationshipsProto)
        }

        return tokenBalances
    }

    internal func getTokenKycStatusFromString(_ tokenKycStatusString: String) throws -> Proto_TokenKycStatus {
        switch tokenKycStatusString {
        case "NOT_APPLICABLE": return Proto_TokenKycStatus.kycNotApplicable
        case "GRANTED": return Proto_TokenKycStatus.granted
        case "REVOKED": return Proto_TokenKycStatus.revoked
        case _: fatalError("Invalid token KYC status: \(tokenKycStatusString)")
        }
    }

    internal func getTokenFreezeStatusFromString(_ tokenFreezeStatusString: String) throws -> Proto_TokenFreezeStatus {
        switch tokenFreezeStatusString {
        case "NOT_APPLICABLE": return Proto_TokenFreezeStatus.freezeNotApplicable
        case "FROZEN": return Proto_TokenFreezeStatus.frozen
        case "UNFROZEN": return Proto_TokenFreezeStatus.unfrozen
        case _: fatalError("Invalid token Freeze status: \(tokenFreezeStatusString)")
        }
    }

}
