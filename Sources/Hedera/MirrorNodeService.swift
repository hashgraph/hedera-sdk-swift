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

import Foundation
import HederaProtobufs
import AsyncHTTPClient

internal final class MirrorNodeService {
    internal var mirrorNodeGateway: MirrorNodeGateway
    
    private init(mirrorNodeGateway: MirrorNodeGateway) {
        self.mirrorNodeGateway = mirrorNodeGateway
    }
    
    internal func getAccountNum(_ evmAddress: String) async throws -> UInt64 {
        let accountInfoResponse = try await self.mirrorNodeGateway.getAccountInfo(evmAddress)
        
        guard let accountId = accountInfoResponse["account"] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error while processing getAccountInfo mirror node query"])
        }
        
        let accountNum = AccountId(String(describing: accountId))?.num
        
        return accountNum!
    }
    
    internal func getAccountEvmAddress(_ num: UInt64) async throws -> EvmAddress {
        let accountInfoResponse = try await self.mirrorNodeGateway.getAccountInfo(String(describing: num))
        
        guard let addressAny = accountInfoResponse["evm_address"] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error while processing getAccountEvmAddress mirror node query"])
        }
        
        let evmAddress = AccountId(String(describing: addressAny))?.evmAddress
        
        return evmAddress!
    }
    
    internal func getContractNum(_ evmAddress: String) async throws -> UInt64 {
        let accountInfoResponse = try await self.mirrorNodeGateway.getContractInfo(evmAddress)
        
        guard let contractId = accountInfoResponse["contract_id"] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error while processing getAccountInfo mirror node query"])
        }
        
        let contractIdNum = ContractId(String(describing: contractId))?.num
        
        return contractIdNum!
    }
    
    internal func getTokenBalancesForAccount(_ evmAddress: String) async throws -> [Proto_TokenBalance] {
        let accountTokensResponse = try await self.mirrorNodeGateway.getAccountTokens(evmAddress)
        
        guard let tokens = accountTokensResponse["tokens"] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error while processing getTokenBalancesForAccount mirror node query"])
        }
        
        var tokenBalances: [Proto_TokenBalance] = []
        
        if let tokensList = tokens as? [[String: Any]] {
            tokensList.forEach {token in
                let tokenId = TokenId(String(describing: token["token_id"]))?.toProtobuf()
                let balance = UInt64(String(describing: token["balance"]))
                let decimals = UInt32(String(describing: token["decimals"]))
                
                let tokenBalanceProto = Proto_TokenBalance.with { proto in
                    proto.tokenID = tokenId!
                    proto.balance = balance!
                    proto.decimals = decimals!
                }
                
                tokenBalances.append(tokenBalanceProto)
            }
        } else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error while processing getTokenBalancesForAccount mirror node query"])
        }
        
        return tokenBalances
    }
    
    internal func getTokenRelationshipsForAccount(_ evmAddress: String) async throws -> [Proto_TokenRelationship] {
        let accountTokensResponse = try await self.mirrorNodeGateway.getAccountTokens(evmAddress)
        
        guard let tokens = accountTokensResponse["tokens"] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error while processing getTokenRelationshipsForAccount mirror node query"])
        }
        
        var tokenBalances: [Proto_TokenRelationship] = []
        
        if let tokensList = tokens as? [[String: Any]] {
            try tokensList.forEach {token in
                let tokenId = TokenId(String(describing: token["token_id"]))?.toProtobuf()
                let balance = UInt64(String(describing: token["balance"]))
                let decimals = UInt32(String(describing: token["decimals"]))
                let kycStatus = String(describing: token["kyc_status"])
                let freezeStatus = String(describing: token["freeze_status"])
                let automaticAssociation = Bool(String(describing: token["automatic_assocation"]))
                
                let tokenRelationshipsProto = try Proto_TokenRelationship.with { proto in
                    proto.tokenID = tokenId!
                    proto.balance = balance!
                    proto.decimals = decimals!
                    proto.kycStatus = try getTokenKycStatusFromString(kycStatus)
                    proto.freezeStatus = try getTokenFreezeStatusFromString(freezeStatus)
                    proto.automaticAssociation = automaticAssociation!
                }
                
                tokenBalances.append(tokenRelationshipsProto)
            }
        } else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error while processing getTokenRelationshipsForAccount mirror node query"])
        }
        
        return tokenBalances
    }
    
    internal func getTokenKycStatusFromString(_ tokenKycStatusString: String) throws -> Proto_TokenKycStatus {
        switch tokenKycStatusString {
        case "NOT_APPLICABLE": return Proto_TokenKycStatus.kycNotApplicable
        case "GRANTED": return Proto_TokenKycStatus.granted
        case "REVOKED": return Proto_TokenKycStatus.revoked
        case _: throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token KYC status: \(tokenKycStatusString)"])
        }
    }
    
    internal func getTokenFreezeStatusFromString(_ tokenFreezeStatusString: String) throws -> Proto_TokenFreezeStatus {
        switch tokenFreezeStatusString {
        case "NOT_APPLICABLE": return Proto_TokenFreezeStatus.freezeNotApplicable
        case "FROZEN": return Proto_TokenFreezeStatus.frozen
        case "UNFROZEN": return Proto_TokenFreezeStatus.unfrozen
        case _: throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid token freeze status: \(tokenFreezeStatusString)"])
        }
    }
    
}
