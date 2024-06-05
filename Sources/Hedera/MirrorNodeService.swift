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

    internal func getTokenBalancesForAccount(_ idNumOrEvmAddress: String) async throws -> [Proto_TokenBalance] {
        let accountTokensResponse = try await self.mirrorNodeGateway.getAccountTokens(idNumOrEvmAddress)

        guard let tokens = accountTokensResponse["tokens"] else {
            throw HError.mirrorNodeQuery("Error in fetching token relationships for account")
        }

        guard let tokensList: [[String: Any]] = tokens as? [[String: Any]] else {
            throw HError.mirrorNodeQuery("Error in converting tokens to array")
        }

        let tokenBalances = try tokensList.map { token in
            guard let id = token["token_id"] as? String, let tokenId = TokenId(id) else {
                throw HError.mirrorNodeQuery("Error while converting `token id` to TokenId")
            }

            guard let balance = token["balance"] as? UInt64 else {
                throw HError.mirrorNodeQuery("Error while converting `balance` to unsigned int")
            }

            guard let decimals = token["decimals"] as? UInt32 else {
                throw HError.mirrorNodeQuery("Error while converting `decimals` to unsigned int")
            }

            return Proto_TokenBalance.with { proto in
                proto.tokenID = tokenId.toProtobuf()
                proto.balance = balance
                proto.decimals = decimals
            }
        }

        return tokenBalances
    }

    internal func getTokenRelationshipsForAccount(_ idNumOrEvmAddress: String) async throws -> [Proto_TokenRelationship]
    {
        let accountTokensResponse = try await self.mirrorNodeGateway.getAccountTokens(idNumOrEvmAddress)

        guard let tokens = accountTokensResponse["tokens"] else {
            throw HError.mirrorNodeQuery("Error in fetching token relationships for account")
        }

        guard let tokensList: [[String: Any]] = tokens as? [[String: Any]] else {
            throw HError.mirrorNodeQuery("Error in converting tokens to array")
        }

        let tokenRelationships = try tokensList.map { token in
            guard let id = token["token_id"] as? String, let tokenId = TokenId(id) else {
                throw HError.mirrorNodeQuery("Error while converting `token id` to TokenId")
            }

            guard let balance = token["balance"] as? UInt64 else {
                throw HError.mirrorNodeQuery("Error while converting `balance` to unsigned int")
            }

            guard let decimals = token["decimals"] as? UInt32 else {
                throw HError.mirrorNodeQuery("Error while converting `decimals` to unsigned int")
            }

            guard let kycStatus = token["kyc_status"] as? String else {
                throw HError.mirrorNodeQuery("Error while converting `kyc status` to string")
            }

            guard let freezeStatus = token["freeze_status"] as? String else {
                throw HError.mirrorNodeQuery("Error while processing freeze status as string")
            }

            guard let automaticAssociation = token["automatic_association"] as? Bool else {
                throw HError.mirrorNodeQuery("Error while processing automatic association from token relationship")
            }

            return try Proto_TokenRelationship.with { proto in
                proto.tokenID = tokenId.toProtobuf()
                proto.balance = balance
                proto.decimals = decimals
                proto.kycStatus = try getTokenKycStatusFromString(kycStatus)
                proto.freezeStatus = try getTokenFreezeStatusFromString(freezeStatus)
                proto.automaticAssociation = automaticAssociation
            }
        }

        return tokenRelationships
    }

    internal func getTokenKycStatusFromString(_ tokenKycStatusString: String) throws -> Proto_TokenKycStatus {
        switch tokenKycStatusString {
        case "NOT_APPLICABLE": return Proto_TokenKycStatus.kycNotApplicable
        case "GRANTED": return Proto_TokenKycStatus.granted
        case "REVOKED": return Proto_TokenKycStatus.revoked
        case _: throw HError.mirrorNodeQuery("Error while processing kyc status from token relationship")
        }
    }

    internal func getTokenFreezeStatusFromString(_ tokenFreezeStatusString: String) throws -> Proto_TokenFreezeStatus {
        switch tokenFreezeStatusString {
        case "NOT_APPLICABLE": return Proto_TokenFreezeStatus.freezeNotApplicable
        case "FROZEN": return Proto_TokenFreezeStatus.frozen
        case "UNFROZEN": return Proto_TokenFreezeStatus.unfrozen
        case _: throw HError.mirrorNodeQuery("Error while processing freeze status from token relationship")
        }
    }

}
