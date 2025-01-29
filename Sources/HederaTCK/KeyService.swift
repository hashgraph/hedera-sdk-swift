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

@testable import Hedera

internal class KeyService {
    /// Singleton instance of KeyService.
    static let service = KeyService()

    ////////////////
    /// INTERNAL ///
    ////////////////

    /// Generate a key. Can be called via JSON-RPC.
    internal func generateKey(_ parameters: [String: JSONObject]) throws -> JSONObject {
        var privateKeys = [JSONObject]()
        let key = try generateKeyHelper(parameters: parameters, privateKeys: &privateKeys)

        if !privateKeys.isEmpty {
            return JSONObject.dictionary(["key": JSONObject.string(key), "privateKeys": JSONObject.list(privateKeys)])
        }

        return JSONObject.dictionary(["key": JSONObject.string(key)])
    }

    /// Get a Hedera Key object from a hex-encoded key string.
    internal func getHederaKey(_ key: String) throws -> Key {
        do {
            return Key.single(try PrivateKey.fromStringDer(key).publicKey)
        } catch {
            do {
                return Key.single(try PublicKey.fromStringDer(key))
            } catch {
                return try Key(protobuf: try Proto_Key(serializedBytes: Data(hexEncoded: key) ?? Data()))
            }
        }
    }

    ///////////////
    /// PRIVATE ///
    ///////////////

    /// Enum of the possible key types.
    private enum KeyType: String {
        case ed25519PrivateKeyType = "ed25519PrivateKey"
        case ed25519PublicKeyType = "ed25519PublicKey"
        case ecdsaSecp256k1PrivateKeyType = "ecdsaSecp256k1PrivateKey"
        case ecdsaSecp256k1PublicKeyType = "ecdsaSecp256k1PublicKey"
        case listKeyType = "keyList"
        case thresholdKeyType = "thresholdKey"
        case evmAddressKeyType = "evmAddress"
    }

    /// Helper function used to generate keys that can be called recursively (useful when generating a KeyList, for example).
    private func generateKeyHelper(
        parameters: [String: JSONObject], privateKeys: inout [JSONObject], isList: Bool = false
    ) throws -> String {
        guard
            let type = KeyType(
                rawValue: try getRequiredJsonParameter("type", parameters, "generateKey"))
        else {
            throw JSONError.invalidParams(
                "generateKey: type is NOT a valid value.")
        }

        let fromKey: String? = try getOptionalJsonParameter("fromKey", parameters, "generateKey")
        if fromKey != nil, type != .ed25519PublicKeyType, type != .ecdsaSecp256k1PublicKeyType,
            type != .evmAddressKeyType
        {
            throw JSONError.invalidParams(
                "generateKey: fromKey MUST NOT be provided for types other than ed25519PublicKey, ecdsaSecp256k1PublicKey, or evmAddress."
            )
        }

        let threshold: Int64? = try getOptionalJsonParameter("threshold", parameters, "generateKey")
        if threshold != nil, type != .thresholdKeyType {
            throw JSONError.invalidParams(
                "generateKey: threshold MUST NOT be provided for types other than thresholdKey.")
        } else if threshold == nil, type == .thresholdKeyType {
            throw JSONError.invalidParams("generateKey: threshold MUST be provided for thresholdKey types.")
        }

        let keys: [JSONObject]? = try getOptionalJsonParameter("keys", parameters, "generateKey")
        if keys != nil, type != .listKeyType, type != .thresholdKeyType {
            throw JSONError.invalidParams(
                "generateKey: keys MUST NOT be provided for types other than keyList or thresholdKey.")
        } else if keys == nil, type == .listKeyType || type == .thresholdKeyType {
            throw JSONError.invalidParams("generateKey: keys MUST be provided for keyList and thresholdKey types.")
        }

        switch type {
        case .ed25519PrivateKeyType, .ecdsaSecp256k1PrivateKeyType:
            let key =
                ((type == .ed25519PrivateKeyType)
                ? PrivateKey.generateEd25519() : PrivateKey.generateEcdsa()).toStringDer()

            if isList {
                privateKeys.append(JSONObject.string(key))
            }

            return key

        case .ed25519PublicKeyType, .ecdsaSecp256k1PublicKeyType:
            if let fromKey = fromKey {
                return try PrivateKey.fromStringDer(fromKey).publicKey.toStringDer()
            }

            let key = (type == .ed25519PublicKeyType) ? PrivateKey.generateEd25519() : PrivateKey.generateEcdsa()

            if isList {
                privateKeys.append(JSONObject.string(key.toStringDer()))
            }

            return key.publicKey.toStringDer()

        case .listKeyType, .thresholdKeyType:
            var keyList: KeyList = []

            /// It's guaranteed at this point that keys is provided, so the unwrap can be safely forced.
            for keyJson in keys! {
                keyList.keys.append(
                    try getHederaKey(
                        generateKeyHelper(
                            parameters: getJson(keyJson, "keys list key", "generateKey"),
                            privateKeys: &privateKeys, isList: true)))
            }

            if type == KeyType.thresholdKeyType {
                /// It's guaranteed at this point that threshold is provided, so the unwrap can be safely forced.
                keyList.threshold = Int(threshold!)
            }

            let keylist = Key.keyList(keyList).toProtobufBytes().hexStringEncoded()
            return keylist

        case .evmAddressKeyType:
            guard let fromKey = fromKey else {
                return PrivateKey.generateEcdsa().publicKey.toEvmAddress()!.toString()
            }

            do {
                return try PrivateKey.fromStringEcdsa(fromKey).publicKey.toEvmAddress()!.toString()
            } catch {
                do {
                    return try PublicKey.fromStringEcdsa(fromKey).toEvmAddress()!.toString()
                } catch {
                    throw JSONError.invalidParams(
                        "generateKey: fromKey for evmAddress MUST be an ECDSAsecp256k1 private or public key.")
                }
            }
        }
    }
}
