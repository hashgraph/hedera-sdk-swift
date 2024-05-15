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

extension Transaction {
    internal struct SignaturePair {
        internal let signature: Data
        internal let publicKey: PublicKey

        internal init(_ pair: (PublicKey, Data)) {
            publicKey = pair.0
            signature = pair.1
        }
    }
}

extension Transaction.SignaturePair: ToProtobuf {
    internal func toProtobuf() -> Proto_SignaturePair {
        .with { proto in
            switch publicKey {
            case _ where publicKey.isEcdsa():
                proto.ecdsaSecp256K1 = signature

            case _ where publicKey.isEd25519():
                proto.ed25519 = signature

            default:
                fatalError("Unknown public key kind")
            }
            proto.pubKeyPrefix = publicKey.toBytesRaw()
        }
    }
}
