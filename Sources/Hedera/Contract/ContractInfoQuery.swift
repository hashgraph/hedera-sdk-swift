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

import GRPC
import HederaProtobufs

/// Get information about a smart contract instance.
public final class ContractInfoQuery: Query<ContractInfo> {
    /// Create a new `ContractInfoQuery`.
    public init(
        contractId: ContractId? = nil
    ) {
        self.contractId = contractId
    }

    /// The contract ID for which information is requested.
    public var contractId: ContractId?

    /// Sets the contract ID for which information is requested.
    @discardableResult
    public func contractId(_ contractId: ContractId) -> Self {
        self.contractId = contractId

        return self
    }

    internal override func toQueryProtobufWith(_ header: Proto_QueryHeader) -> Proto_Query {

        .with { proto in
            proto.contractGetInfo = .with { proto in
                proto.header = header
                contractId?.toProtobufInto(&proto.contractID)
            }
        }
    }

    internal override func queryExecute(_ channel: GRPCChannel, _ request: Proto_Query) async throws -> Proto_Response {
        try await Proto_SmartContractServiceAsyncClient(channel: channel).getContractInfo(request)
    }

    internal override func makeQueryResponse(_ context: MirrorNetworkContext, _ response: Proto_Response.OneOf_Response)
        async throws
        -> Response
    {
        let mirrorNodeGateway = try MirrorNodeGateway.forNetwork(context.mirrorNetworkNodes, context.ledgerId)
        let mirrorNodeService = MirrorNodeService.init(mirrorNodeGateway)

        guard case .contractGetInfo(let proto) = response else {
            throw HError.fromProtobuf("unexpected \(response) received, expected `contractGetInfo`")
        }

        let contractInfo = try ContractInfo.fromProtobuf(proto.contractInfo)
        let tokenRelationshipsProto = try await mirrorNodeService.getTokenRelationshipsForAccount(
            String(describing: contractInfo.contractId.num))

        var tokenRelationships: [TokenId: TokenRelationship] = [:]

        for relationship in tokenRelationshipsProto {
            tokenRelationships[.fromProtobuf(relationship.tokenID)] = try TokenRelationship.fromProtobuf(relationship)
        }

        return ContractInfo(
            contractId: contractInfo.contractId,
            accountId: contractInfo.accountId,
            contractAccountId: contractInfo.contractAccountId,
            adminKey: contractInfo.adminKey,
            expirationTime: contractInfo.expirationTime,
            autoRenewPeriod: contractInfo.autoRenewPeriod,
            storage: contractInfo.storage,
            contractMemo: contractInfo.contractMemo,
            balance: contractInfo.balance,
            isDeleted: contractInfo.isDeleted,
            autoRenewAccountId: contractInfo.autoRenewAccountId,
            maxAutomaticTokenAssociations: contractInfo.maxAutomaticTokenAssociations,
            tokenRelationships: tokenRelationships,
            ledgerId: contractInfo.ledgerId,
            stakingInfo: contractInfo.stakingInfo
        )
    }

    internal override func validateChecksums(on ledgerId: LedgerId) throws {
        try contractId?.validateChecksums(on: ledgerId)
        try super.validateChecksums(on: ledgerId)
    }
}
