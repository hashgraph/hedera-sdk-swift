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

/// Reject undesired Tokens or NFTs.
public final class TokenRejectTransaction: Transaction {
    /// Create a new `TokenRejectTransaction`.
    public init(
        owner: AccountId? = nil,
        tokenIds: [TokenId] = [],
        nftIds: [NftId] = []
    ) {
        self.owner = owner
        self.tokenIds = tokenIds
        self.nftIds = nftIds

        super.init()
    }

    internal init(protobuf proto: Proto_TransactionBody, _ data: Proto_TokenRejectTransactionBody) throws {
        self.owner = data.hasOwner ? try .fromProtobuf(data.owner) : nil
        self.tokenIds = []
        self.nftIds = []

        for reference in data.rejections {
            switch reference.tokenIdentifier {
            case .fungibleToken(let tokenId):
                self.tokenIds.append(TokenId(protobuf: tokenId))
            case .nft(let nftId):
                self.nftIds.append(NftId(protobuf: nftId))
            default:
                throw HError.fromProtobuf("invalid token identifier")
            }
        }

        try super.init(protobuf: proto)
    }

    /// The account holding the token to be rejected.
    public var owner: AccountId? {
        willSet {
            ensureNotFrozen()
        }
    }

    /// Sets account holding the token to be rejected.
    @discardableResult
    public func owner(_ owner: AccountId) -> Self {
        self.owner = owner

        return self
    }

    public var tokenIds: [TokenId] {
        willSet {
            ensureNotFrozen()
        }
    }

    @discardableResult
    public func tokenIds(_ tokenIds: [TokenId]) -> Self {
        self.tokenIds = tokenIds

        return self
    }

    /// Append a fungible token to the list of tokens to be rejected.
    @discardableResult
    public func addTokenId(_ tokenId: TokenId) -> Self {
        self.tokenIds.append(tokenId)

        return self
    }

    public var nftIds: [NftId] {
        willSet {
            ensureNotFrozen()
        }
    }

    @discardableResult
    public func nftIds(_ nftIds: [NftId]) -> Self {
        self.nftIds = nftIds

        return self
    }

    /// Append an NFT to the list of tokens to be rejected.
    @discardableResult
    public func addNftId(_ nftId: NftId) -> Self {
        self.nftIds.append(nftId)

        return self
    }

    internal override func validateChecksums(on ledgerId: LedgerId) throws {
        try owner?.validateChecksums(on: ledgerId)
        try super.validateChecksums(on: ledgerId)
    }

    internal override func transactionExecute(_ channel: GRPCChannel, _ request: Proto_Transaction) async throws
        -> Proto_TransactionResponse
    {
        try await Proto_TokenServiceAsyncClient(channel: channel).rejectToken(request)
    }

    internal override func toTransactionDataProtobuf(_ chunkInfo: ChunkInfo) -> Proto_TransactionBody.OneOf_Data {
        _ = chunkInfo.assertSingleTransaction()

        return .tokenReject(toProtobuf())
    }
}

extension TokenRejectTransaction: ToProtobuf {
    internal typealias Protobuf = Proto_TokenRejectTransactionBody

    internal func toProtobuf() -> Protobuf {
        .with { [self] proto in
            owner?.toProtobufInto(&proto.owner)

            for tokenId in self.tokenIds {
                proto.rejections.append(.with { $0.fungibleToken = tokenId.toProtobuf() })
            }

            for nftId in self.nftIds {
                proto.rejections.append(.with { $0.nft = nftId.toProtobuf() })
            }
        }
    }
}

extension TokenRejectTransaction {
    internal func toSchedulableTransactionData() -> Proto_SchedulableTransactionBody.OneOf_Data {
        .tokenReject(toProtobuf())
    }
}
