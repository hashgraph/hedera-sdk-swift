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

class SDKClient {
    var client: Client

    init() {
        self.client = Client.forTestnet()
    }

    internal enum KeyType: String {
        case ed25519PrivateKeyType = "ed25519PrivateKey"
        case ed25519PublicKeyType = "ed25519PublicKey"
        case ecdsaSecp256k1PrivateKeyType = "ecdsaSecp256k1PrivateKey"
        case ecdsaSecp256k1PublicKeyType = "ecdsaSecp256k1PublicKey"
        case listKeyType = "keyList"
        case thresholdKeyType = "thresholdKey"
        case evmAddressKeyType = "evmAddress"
    }

    private func verifyJsonRequestParameters(parameters: JSONObject?, functionName: String) throws -> [String: JSONObject] {
        /// Parameters MUST be provided.
        guard let paramsJson = parameters else {
            throw JSONError.invalidParams("\(functionName): parameters MUST be provided.")
        }

        /// Parameters MUST be a dictionary.
        guard let paramsAsDictionary = paramsJson.dictValue else {
            throw JSONError.invalidParams("\(functionName): parameters MUST be a dictionary.")
        }

        return paramsAsDictionary
    }

    private func generateKeyHelper(parameters: [String: JSONObject], privateKeys: inout [JSONObject], isList: Bool = false) throws -> String {
        /// A type MUST be provided.
        guard let typeJson = parameters["type"] else {
            throw JSONError.invalidParams("generateKey: type MUST be provided.")
        }

        /// The type MUST be a string.
        guard let typeAsString = typeJson.stringValue else {
            throw JSONError.invalidParams("generateKey: type MUST be a string.")
        }

        /// The type MUST be recognizable.
        guard let type = KeyType(rawValue: typeAsString) else {
            throw JSONError.invalidParams("generateKey: type MUST be one of the valid types.", JSONObject.string(typeAsString))
        }

        var fromKey: String?
        if let fromKeyJson = parameters["fromKey"] {
            /// fromKey MUST NOT be provided for types that are not ed25519PublicKeyType, ecdsaSecp256k1PublicKeyType, or evmAddressKeyType.
            if type != .ed25519PublicKeyType, type != .ecdsaSecp256k1PublicKeyType, type != .evmAddressKeyType {
                throw JSONError.invalidParams("generateKey: fromKey MUST NOT be provided for types other than ed25519PublicKey, ecdsaSecp256k1PublicKey, or evmAddress.")
            }

            /// If provided, fromKey MUST be a string.
            guard let fromKeyAsString = fromKeyJson.stringValue else {
                throw JSONError.invalidParams("generateKey: fromKey MUST be a string.")
            }

            fromKey = fromKeyAsString
        }

        var threshold: Int?
        if let thresholdJson = parameters["threshold"] {
            /// threshold MUST NOT be provided for types that are not thresholdKeyType.
            if type != .thresholdKeyType {
                throw JSONError.invalidParams("generateKey: threshold MUST be provided for thresholdKey types.")
            }

            /// If threshold is provided, it MUST be an int.
            guard let thresholdAsInt = thresholdJson.intValue else {
                throw JSONError.invalidParams("generateKey: threshold MUST be an integer.")
            }

            threshold = thresholdAsInt
        } else {
            /// threshold MUST be provided for thresholdKeyTypes.
            if type == .thresholdKeyType {
                throw JSONError.invalidParams("generateKey: threshold MUST be provided for thresholdKey types.")
            }
        }

        var keys: [JSONObject]?
        if let keyListJson = parameters["keys"] {
            /// keys MUST NOT be provided for types that are not listKeyType or thresholdKeyType.
            if type != .listKeyType, type != .thresholdKeyType {
                throw JSONError.invalidParams("generateKey: keys MUST NOT be provided for types other than keyList or thresholdKey.")
            }

            /// If keys are provided, it MUST be a list.
            guard let keysAsList = keyListJson.listValue else {
                throw JSONError.invalidParams("generateKey: keys MUST be a list.")
            }

            keys = keysAsList
        } else {
            /// keys MUST be provided for listKeyTypes and thresholdKeyTypes.
            if type == .listKeyType || type == .thresholdKeyType {
                throw JSONError.invalidParams("generateKey: keys MUST be provided for keyList and thresholdKey types.")
            }
        }

        switch type {
        case .ed25519PrivateKeyType:
            fallthrough
        case .ecdsaSecp256k1PrivateKeyType:
            let key = (type == .ed25519PublicKeyType) ? PrivateKey.generateEd25519().toStringDer() : PrivateKey.generateEcdsa().toStringDer()

            /// If this private key is being generated as part of a KeyList or ThresholdKey, add it to the privateKeys list.
            if isList {
                privateKeys.append(JSONObject.string(key))
            }

            return key

        case .ed25519PublicKeyType:
            fallthrough
        case .ecdsaSecp256k1PublicKeyType:
            /// Generate the public key from the fromKey if provided.
            if let fromKey = fromKey {
                return try PrivateKey.fromStringDer(fromKey).publicKey.toStringDer()
            }

            let key = (type == .ed25519PublicKeyType) ? PrivateKey.generateEd25519() : PrivateKey.generateEcdsa()

            /// If this public key is being generated as part of a KeyList or ThresholdKey, add its private key to the privateKeys list.
            if isList {
                privateKeys.append(JSONObject.string(key.toStringDer()))
            }

            return key.publicKey.toStringDer()

        case .listKeyType:
            fallthrough
        case .thresholdKeyType:
            var keyList: KeyList = []

            /// It's guaranteed at this point that keys is provided, so the unwrap can be safely forced.
            for keyJson in keys! {
                /// The key JSON parameters MUST be a dictionary.
                guard let keyAsDictionary = keyJson.dictValue else {
                    throw JSONError.invalidParams("generateKey: key parameters MUST be a dictionary.")
                }

                /// Recursively call to generate the key in the list of keys. Mark that the key is being generated as part of a list.
                let generatedKeyString = try generateKeyHelper(parameters: keyAsDictionary, privateKeys: &privateKeys, isList: true)

                /// Determine the generated key type and add it to the key list.
                do {
                    keyList.keys.append(Key.single(try PrivateKey.fromStringDer(generatedKeyString).publicKey))
                } catch {
                    do {
                        keyList.keys.append(Key.single(try PublicKey.fromStringDer(generatedKeyString)))
                    } catch {
                        keyList.keys.append(try Key(protobuf: try Proto_Key(serializedData: Data(hex: generatedKeyString))))
                    }
                }
            }

            if type == KeyType.thresholdKeyType {
                keyList.threshold = threshold
            }

            return Key.keyList(keyList).toProtobufBytes().toHexString()

        case .evmAddressKeyType:
            /// If fromKey is not provided, generate from a randomly generated ECDSAsecp256k1 key.
            guard let fromKey = fromKey else {
                return PrivateKey.generateEcdsa().publicKey.toEvmAddress()!.toString()
            }

            do {
                return try PrivateKey.fromStringEcdsa(fromKey).publicKey.toEvmAddress()!.toString()
            } catch {
                do {
                    return try PublicKey.fromStringEcdsa(fromKey).toEvmAddress()!.toString()
                } catch {
                    throw JSONError.invalidParams("generateKey: fromKey for evmAddress MUST be an ECDSAsecp256k1 private or public key.")
                }
            }
        }
    }

    func generateKey(parameters: JSONObject?) throws -> JSONObject {
        /// Verify JSON request parameters exist and are well-formed.
        let params = try verifyJsonRequestParameters(parameters: parameters, functionName: #function)

        var privateKeys = [JSONObject]()
        let key = try generateKeyHelper(parameters: params, privateKeys: &privateKeys)

        /// If private keys were added to the privateKeys list, add the list to the return object.
        if !privateKeys.isEmpty {
            return JSONObject.dictionary(["key" : JSONObject.string(key), "privateKeys" : JSONObject.list(privateKeys)])
        }

        return JSONObject.dictionary(["key" : JSONObject.string(key)])
    }

    func reset() throws -> JSONObject {
        self.client = try Client.forNetwork([String: AccountId]())
        return JSONObject.dictionary(["status": JSONObject.string("SUCCESS")])                                              
    }

    func setup(parameters: JSONObject?) throws -> JSONObject {
        /// Verify JSON request parameters exist and are well-formed.
        let params = try verifyJsonRequestParameters(parameters: parameters, functionName: #function)

        /// The operator account ID MUST be provided.
        guard let operatorAccountIdJson = params["operatorAccountId"] else {
            throw JSONError.invalidParams("\(#function): operatorAccountId MUST be provided.")
        }

        /// The operator account ID MUST be a string.
        guard let operatorAccountIdAsString = operatorAccountIdJson.stringValue else {
            throw JSONError.invalidParams("\(#function): operatorAccountId MUST be a string.")
        }

        let operatorAccountId = try AccountId.fromString(operatorAccountIdAsString)

        /// The operator private key MUST be provided.
        guard let operatorPrivateKeyJson = params["operatorPrivateKey"] else {
            throw JSONError.invalidParams("\(#function): operatorAccountId MUST be provided.")
        }

        /// The operator private key MUST be a string.
        guard let operatorPrivateKeyAsString = operatorPrivateKeyJson.stringValue else {
            throw JSONError.invalidParams("\(#function): operatorPrivateKey MUST be a string.")
        }

        let operatorPrivateKey = try PrivateKey.fromStringDer(operatorPrivateKeyAsString)

        /// All the parameters for a custom network must be provided, or none of them should be provided.
        var clientType: String
        let nodeIpJson = params["nodeIp"]
        let nodeAccountIdJson = params["nodeAccountId"]
        let mirrorNetworkIpJson = params["mirrorNetworkIp"]

        if nodeIpJson == nil, nodeAccountIdJson == nil, mirrorNetworkIpJson == nil {
            /// If none of the parameters were provided, a testnet connection should be established.
            self.client = Client.forTestnet()
            clientType = "testnet"
        } else if nodeIpJson != nil && nodeAccountIdJson != nil && mirrorNetworkIpJson != nil {
            /// If all the parameters were provided, they MUST be strings.
            guard let nodeIp = nodeIpJson?.stringValue else {
                throw JSONError.invalidParams("\(#function): nodeIp MUST be a string.")
            }

            guard let nodeAccountId = nodeAccountIdJson?.stringValue else {
                throw JSONError.invalidParams("\(#function): nodeAccountId MUST be a string.")
            }

            guard let mirrorNetworkIp = mirrorNetworkIpJson?.stringValue else {
                throw JSONError.invalidParams("\(#function): mirrorNetworkIp MUST be a string.")
            }

            /// Set the parameters.
            self.client = try Client.forNetwork([nodeIp : AccountId.fromString(nodeAccountId)])
            self.client.setMirrorNetwork([mirrorNetworkIp])
            clientType = "custom"
        } else {
            throw JSONError.invalidParams("\(#function): all custom network parameters (nodeIp, nodeAccountId, mirrorNetworkIp) MUST or MUST NOT all be provided.")
        }

        // The operator can be set.
        self.client.setOperator(operatorAccountId, operatorPrivateKey)

        /// Client setup successful.
        return JSONObject.dictionary(["message": JSONObject.string("Successfully setup " + clientType + " client."),
                                      "success": JSONObject.string("SUCCESS")])

    }
}
