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
    private var client: Client

    public init() {
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

    private func getHederaKey(_ key: String) throws -> Key {
        do {
            return Key.single(try PrivateKey.fromStringDer(key).publicKey)
        } catch {
            do {
                return Key.single(try PublicKey.fromStringDer(key))
            } catch {
                return try Key(protobuf: try Proto_Key(serializedData: Data(hex: key)))
            }
        }
    }

    private func generateKeyHelper(
        parameters: [String: JSONObject], privateKeys: inout [JSONObject], isList: Bool = false
    ) throws -> String {
        guard let type = KeyType(rawValue: try getRequiredStringParameter("type", parameters, "generateKey")) else {
            throw JSONError.invalidParams(
                "generateKey: type is NOT a valid value.")
        }

        let fromKey = try getOptionalStringParameter("fromKey", parameters, "generateKey")
        if fromKey != nil, type != .ed25519PublicKeyType, type != .ecdsaSecp256k1PublicKeyType, type != .evmAddressKeyType {
            throw JSONError.invalidParams(
                "generateKey: fromKey MUST NOT be provided for types other than ed25519PublicKey, ecdsaSecp256k1PublicKey, or evmAddress."
            )
        }

        let threshold = try getOptionalIntParameter("threshold", parameters, "generateKey")
        if threshold != nil, type != .thresholdKeyType {
            throw JSONError.invalidParams("generateKey: threshold MUST be provided for thresholdKey types.")
        } else if threshold == nil, type == .thresholdKeyType {
            throw JSONError.invalidParams("generateKey: threshold MUST be provided for thresholdKey types.")
        }

        let keys = try getOptionalListParameter("keys", parameters, "generateKey")
        if keys != nil, type != .listKeyType, type != .thresholdKeyType {
            throw JSONError.invalidParams("generateKey: keys MUST NOT be provided for types other than keyList or thresholdKey.")
        } else if keys == nil, type == .listKeyType || type == .thresholdKeyType {
            throw JSONError.invalidParams("generateKey: keys MUST be provided for keyList and thresholdKey types.")
        }

        switch type {
        case .ed25519PrivateKeyType, .ecdsaSecp256k1PrivateKeyType:
            let key =
                ((type == .ed25519PublicKeyType)
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
                            parameters: getJsonAsDict(keyJson, "keys list key", "generateKey"),
                            privateKeys: &privateKeys, isList: true)))
            }

            if type == KeyType.thresholdKeyType {
                /// It's guaranteed at this point that threshold is provided, so the unwrap can be safely forced.
                keyList.threshold = Int(threshold!)
            }

            return Key.keyList(keyList).toProtobufBytes().toHexString()

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

    private func fillOutCommonTransactionParameters<T: Transaction>(
        _ transaction: inout T, params: [String: JSONObject], client: Client, function: String
    )
        throws
    {
        if let transactionId = try getOptionalStringParameter("transactionId", params, function) {
            transaction.transactionId = try TransactionId.fromString(transactionId)
        }

        if let maxTransactionFee = try getOptionalIntParameter("maxTransactionFee", params, function) {
            transaction.maxTransactionFee = Hbar.fromTinybars(maxTransactionFee)
        }

        if let validTransactionDuration = try getOptionalIntParameter("validTransactionDuration", params, function) {
            transaction.transactionValidDuration = Duration(seconds: UInt64(validTransactionDuration))
        }

        if let memo = try getOptionalStringParameter("memo", params, function) {
            transaction.transactionMemo = memo
        }

        if let regenerateTransactionId = try getOptionalBooleanParameter("regenerateTransactionId", params, function) {
            transaction.regenerateTransactionId = regenerateTransactionId
        }

        if let signers = try getOptionalListParameter("signers", params, function) {
            try transaction.freezeWith(client)
            for signer in signers {
                transaction.sign(
                    try PrivateKey.fromStringDer(getJsonAsString(signer, "signers list element", "generateKey")))
            }
        }
    }

    public func createAccount(_ parameters: [String: JSONObject]?) async throws -> JSONObject {
        var accountCreateTransaction = AccountCreateTransaction()

        if let params = parameters {
            if let key = try getOptionalStringParameter("key", params, #function) {
                accountCreateTransaction.key = try getHederaKey(key)
            }

            if let initialBalance = try getOptionalIntParameter(
                "initialBalance", params, #function)
            {
                accountCreateTransaction.initialBalance = Hbar.fromTinybars(initialBalance)
            }

            if let receiverSignatureRequired = try getOptionalBooleanParameter(
                "receiverSignatureRequired", params, #function)
            {
                accountCreateTransaction.receiverSignatureRequired = receiverSignatureRequired
            }

            if let autoRenewPeriod = try getOptionalIntParameter(
                "autoRenewPeriod", params, #function)
            {
                accountCreateTransaction.autoRenewPeriod = Duration(seconds: UInt64(truncatingIfNeeded: autoRenewPeriod))
            }

            if let memo = try getOptionalStringParameter("memo", params, #function) {
                accountCreateTransaction.accountMemo = memo
            }

            if let maxAutoTokenAssociations = try getOptionalIntParameter(
                "maxAutoTokenAssociations", params, #function)
            {
                accountCreateTransaction.maxAutomaticTokenAssociations = UInt32(maxAutoTokenAssociations)
            }

            if let stakedAccountId = try getOptionalStringParameter(
                "stakedAccountId", params, #function)
            {
                accountCreateTransaction.stakedAccountId = try AccountId.fromString(stakedAccountId)
            }

            if let stakedNodeId = try getOptionalIntParameter(
                "stakedNodeId", params, #function)
            {
                accountCreateTransaction.stakedNodeId = UInt64(truncatingIfNeeded: stakedNodeId)
            }

            if let declineStakingReward = try getOptionalBooleanParameter(
                "declineStakingReward", params, #function)
            {
                accountCreateTransaction.declineStakingReward = declineStakingReward
            }

            if let alias = try getOptionalStringParameter("alias", params, #function) {
                accountCreateTransaction.alias = try EvmAddress.fromString(alias)
            }

            if let commonTransactionParams = try getOptionalDictParameter(
                "commonTransactionParams", params, #function)
            {
                try fillOutCommonTransactionParameters(
                    &accountCreateTransaction, params: commonTransactionParams, client: self.client, function: #function
                )
            }
        }

        let txReceipt = try await accountCreateTransaction.execute(client).getReceipt(client)
        return JSONObject.dictionary([
            "accountId": JSONObject.string(txReceipt.accountId!.toString()),
            "status": JSONObject.string(txReceipt.status.description),
        ])
    }

    public func generateKey(_ parameters: [String: JSONObject]) throws -> JSONObject {
        var privateKeys = [JSONObject]()
        let key = try generateKeyHelper(parameters: parameters, privateKeys: &privateKeys)

        if !privateKeys.isEmpty {
            return JSONObject.dictionary(["key": JSONObject.string(key), "privateKeys": JSONObject.list(privateKeys)])
        }

        return JSONObject.dictionary(["key": JSONObject.string(key)])
    }

    public func reset() throws -> JSONObject {
        self.client = try Client.forNetwork([String: AccountId]())
        return JSONObject.dictionary(["status": JSONObject.string("SUCCESS")])
    }

    public func setup(_ parameters: [String: JSONObject]) throws -> JSONObject {
        let operatorAccountId = try AccountId.fromString(
            getRequiredStringParameter("operatorAccountId", parameters, #function))
        let operatorPrivateKey = try PrivateKey.fromStringDer(
            getRequiredStringParameter("operatorPrivateKey", parameters, #function))

        var clientType: String
        let nodeIp = try getOptionalStringParameter("nodeIp", parameters, #function)
        let nodeAccountId = try getOptionalStringParameter("nodeAccountId", parameters, #function)
        let mirrorNetworkIp = try getOptionalStringParameter("mirrorNetworkIp", parameters, #function)

        if nodeIp == nil, nodeAccountId == nil, mirrorNetworkIp == nil {
            self.client = Client.forTestnet()
            clientType = "testnet"
        } else if let nodeIp = nodeIp, let nodeAccountId = nodeAccountId, let mirrorNetworkIp = mirrorNetworkIp {
            self.client = try Client.forNetwork([nodeIp: AccountId.fromString(nodeAccountId)])
            self.client.setMirrorNetwork([mirrorNetworkIp])
            clientType = "custom"
        } else {
            throw JSONError.invalidParams(
                "\(#function): custom network parameters (nodeIp, nodeAccountId, mirrorNetworkIp) SHALL or SHALL NOT all be provided."
            )
        }

        self.client.setOperator(operatorAccountId, operatorPrivateKey)

        return JSONObject.dictionary([
            "message": JSONObject.string("Successfully setup " + clientType + " client."),
            "success": JSONObject.string("SUCCESS"),
        ])

    }
}
