/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
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

/// Any method that can be used to authorize an operation on Hedera.
public enum Key: Sendable, Equatable {
    case single(PublicKey)
    case contractId(ContractId)

    /// A delegatable contract ID.
    case delegateContractId(DelegateContractId)

    case keyList(KeyList)

    /// Convert this key to protobuf encoded bytes.
    public func toBytes() -> Data {
        toProtobufBytes()
    }
}

extension Key: TryProtobufCodable {
    internal typealias Protobuf = Proto_Key

    internal init(protobuf proto: Protobuf) throws {
        guard let key = proto.key else {
            throw HError.fromProtobuf("unexpected empty key in Key")
        }

        switch key {
        case .contractID(let contractId):
            self = .contractId(try .fromProtobuf(contractId))
        case .ed25519(let ed25519Bytes):
            self = .single(try .fromBytesEd25519(ed25519Bytes))
        case .rsa3072:
            throw HError.fromProtobuf("unsupported key kind: Rsa3072")
        case .ecdsa384:
            throw HError.fromProtobuf("unsupported key kind: Rsa384")
        case .thresholdKey(let thresholdKey):
            self = .keyList(try .fromProtobuf(thresholdKey))
        case .keyList(let keyList):
            self = .keyList(try .fromProtobuf(keyList))
        case .ecdsaSecp256K1(let ecdsaBytes):
            self = .single(try .fromBytesEcdsa(ecdsaBytes))
        case .delegatableContractID(let contractId):
            self = .delegateContractId(try .fromProtobuf(contractId))
        }
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            // this is make sure we set the property by having a `let` constant that *must* be assigned to
            // (we get a compiler error otherwise)
            let key: Protobuf.OneOf_Key
            switch self {
            case .single(let single):
                let bytes = single.toBytesRaw()
                key = single.isEd25519() ? .ed25519(bytes) : .ecdsaSecp256K1(bytes)
            case .contractId(let contractId):
                key = .contractID(contractId.toProtobuf())
            case .delegateContractId(let delegatableContractId):
                key = .delegatableContractID(delegatableContractId.toProtobuf())
            case .keyList(let keyList):
                key = keyList.toProtobufKey()
            }

            proto.key = key
        }
    }
}
