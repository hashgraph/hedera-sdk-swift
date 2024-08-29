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
import NumberKit

@testable import Hedera

internal class SDKClient {
    private var client: Client

    internal init() {
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
                return try Key(protobuf: try Proto_Key(serializedBytes: Data(hex: key)))
            }
        }
    }

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

        let threshold: Int? = try getOptionalJsonParameter("threshold", parameters, "generateKey")
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
                            parameters: getJson(keyJson, "keys list key", "generateKey"),
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
        if let transactionId: String = try getOptionalJsonParameter("transactionId", params, function) {
            transaction.transactionId = try TransactionId.fromString(transactionId)
        }

        if let maxTransactionFee: Int64 = try getOptionalJsonParameter("maxTransactionFee", params, function) {
            transaction.maxTransactionFee = Hbar.fromTinybars(maxTransactionFee)
        }

        if let validTransactionDuration: UInt64 = try getOptionalJsonParameter(
            "validTransactionDuration", params, function)
        {
            transaction.transactionValidDuration = Duration(seconds: validTransactionDuration)
        }

        if let memo: String = try getOptionalJsonParameter("memo", params, function) {
            transaction.transactionMemo = memo
        }

        if let regenerateTransactionId: Bool = try getOptionalJsonParameter("regenerateTransactionId", params, function)
        {
            transaction.regenerateTransactionId = regenerateTransactionId
        }

        if let signers: [JSONObject] = try getOptionalJsonParameter("signers", params, function) {
            try transaction.freezeWith(client)
            for signer in signers {
                transaction.sign(
                    try PrivateKey.fromStringDer(getJson(signer, "signers list element", "generateKey") as String))
            }
        }
    }

    internal func createAccount(_ parameters: [String: JSONObject]?) async throws -> JSONObject {
        var accountCreateTransaction = AccountCreateTransaction()

        if let params = parameters {
            if let key: String = try getOptionalJsonParameter("key", params, #function) {
                accountCreateTransaction.key = try getHederaKey(key)
            }

            if let initialBalance: Int64 = try getOptionalJsonParameter(
                "initialBalance", params, #function)
            {
                accountCreateTransaction.initialBalance = Hbar.fromTinybars(initialBalance)
            }

            if let receiverSignatureRequired: Bool = try getOptionalJsonParameter(
                "receiverSignatureRequired", params, #function)
            {
                accountCreateTransaction.receiverSignatureRequired = receiverSignatureRequired
            }

            if let autoRenewPeriod: Int64 = try getOptionalJsonParameter(
                "autoRenewPeriod", params, #function)
            {
                accountCreateTransaction.autoRenewPeriod = Duration(
                    seconds: UInt64(truncatingIfNeeded: autoRenewPeriod))
            }

            if let memo: String = try getOptionalJsonParameter("memo", params, #function) {
                accountCreateTransaction.accountMemo = memo
            }

            if let maxAutoTokenAssociations: Int64 = try getOptionalJsonParameter(
                "maxAutoTokenAssociations", params, #function)
            {
                accountCreateTransaction.maxAutomaticTokenAssociations =
                    Int32(truncatingIfNeeded: maxAutoTokenAssociations)
            }

            if let stakedAccountId: String = try getOptionalJsonParameter(
                "stakedAccountId", params, #function)
            {
                accountCreateTransaction.stakedAccountId = try AccountId.fromString(stakedAccountId)
            }

            if let stakedNodeId: Int64 = try getOptionalJsonParameter(
                "stakedNodeId", params, #function)
            {
                accountCreateTransaction.stakedNodeId = UInt64(truncatingIfNeeded: stakedNodeId)
            }

            if let declineStakingReward: Bool = try getOptionalJsonParameter(
                "declineStakingReward", params, #function)
            {
                accountCreateTransaction.declineStakingReward = declineStakingReward
            }

            if let alias: String = try getOptionalJsonParameter("alias", params, #function) {
                accountCreateTransaction.alias = try EvmAddress.fromString(alias)
            }

            if let commonTransactionParams: [String: JSONObject] = try getOptionalJsonParameter(
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

    internal func createToken(_ parameters: [String: JSONObject]?) async throws -> JSONObject {
        var tokenCreateTransaction = TokenCreateTransaction()

        if let params = parameters {
            if let name: String = try getOptionalJsonParameter("name", params, #function) {
                tokenCreateTransaction.name = name
            }

            if let symbol: String = try getOptionalJsonParameter("symbol", params, #function) {
                tokenCreateTransaction.symbol = symbol
            }

            if let decimals: UInt32 = try getOptionalJsonParameter("decimals", params, #function) {
                tokenCreateTransaction.decimals = decimals
            }

            if let initialSupply: UInt64 = try getOptionalJsonParameter("initialSupply", params, #function) {
                tokenCreateTransaction.initialSupply = initialSupply
            }

            if let treasuryAccountId: String = try getOptionalJsonParameter("treasuryAccountId", params, #function) {
                tokenCreateTransaction.treasuryAccountId = try AccountId.fromString(treasuryAccountId)
            }

            if let adminKey: String = try getOptionalJsonParameter("adminKey", params, #function) {
                tokenCreateTransaction.adminKey = try getHederaKey(adminKey)
            }

            if let kycKey: String = try getOptionalJsonParameter("kycKey", params, #function) {
                tokenCreateTransaction.kycKey = try getHederaKey(kycKey)
            }

            if let freezeKey: String = try getOptionalJsonParameter("freezeKey", params, #function) {
                tokenCreateTransaction.freezeKey = try getHederaKey(freezeKey)
            }

            if let wipeKey: String = try getOptionalJsonParameter("wipeKey", params, #function) {
                tokenCreateTransaction.wipeKey = try getHederaKey(wipeKey)
            }

            if let supplyKey: String = try getOptionalJsonParameter("supplyKey", params, #function) {
                tokenCreateTransaction.supplyKey = try getHederaKey(supplyKey)
            }

            if let freezeDefault: Bool = try getOptionalJsonParameter("freezeDefault", params, #function) {
                tokenCreateTransaction.freezeDefault = freezeDefault
            }

            if let expirationTime: Int64 = try getOptionalJsonParameter("expirationTime", params, #function) {
                tokenCreateTransaction.expirationTime = Timestamp(
                    from: Date(timeIntervalSince1970: TimeInterval(expirationTime)))
            }

            if let autoRenewAccountId: String = try getOptionalJsonParameter("autoRenewAccountId", params, #function) {
                tokenCreateTransaction.autoRenewAccountId = try AccountId.fromString(autoRenewAccountId)
            }

            if let autoRenewPeriod: Int64 = try getOptionalJsonParameter("autoRenewPeriod", params, #function) {
                tokenCreateTransaction.autoRenewPeriod = Duration(seconds: UInt64(truncatingIfNeeded: autoRenewPeriod))
            }

            if let memo: String = try getOptionalJsonParameter("memo", params, #function) {
                tokenCreateTransaction.tokenMemo = memo
            }

            if let tokenType: String = try getOptionalJsonParameter("tokenType", params, #function) {
                guard tokenType == "ft" || tokenType == "nft" else {
                    throw JSONError.invalidParams("\(#function): tokenType MUST be 'ft' or 'nft'.")
                }
                tokenCreateTransaction.tokenType =
                    tokenType == "ft" ? TokenType.fungibleCommon : TokenType.nonFungibleUnique
            }

            if let supplyType: String = try getOptionalJsonParameter("supplyType", params, #function) {
                guard supplyType == "finite" || supplyType == "infinite" else {
                    throw JSONError.invalidParams("\(#function): supplyType MUST be 'finite' or 'infinite'.")
                }
                tokenCreateTransaction.tokenSupplyType =
                    supplyType == "finite" ? TokenSupplyType.finite : TokenSupplyType.infinite
            }

            if let maxSupply: Int64 = try getOptionalJsonParameter("maxSupply", params, #function) {
                tokenCreateTransaction.maxSupply = UInt64(truncatingIfNeeded: maxSupply)
            }

            if let feeScheduleKey: String = try getOptionalJsonParameter("feeScheduleKey", params, #function) {
                tokenCreateTransaction.feeScheduleKey = try getHederaKey(feeScheduleKey)
            }

            if let customFees: [JSONObject] = try getOptionalJsonParameter("customFees", params, #function) {
                var fees = [AnyCustomFee]()
                for feeAsJson in customFees {
                    /// A fee MUST be a dictionary.
                    guard let fee = feeAsJson.dictValue else {
                        throw JSONError.invalidParams("\(#function): fee MUST be a dictionary type.")
                    }

                    let feeCollectorAccountId: AccountId = try AccountId.fromString(
                        getRequiredJsonParameter("feeCollectorAccountId", fee, #function) as String)
                    let feeCollectorsExempt: Bool = try getRequiredJsonParameter("feeCollectorsExempt", fee, #function)

                    /// Make sure only one of the three fee types is provided.
                    guard
                        let fixedFee: [String: JSONObject]? = try getOptionalJsonParameter("fixedFee", fee, #function),
                        let fractionalFee: [String: JSONObject]? = try getOptionalJsonParameter(
                            "fractionalFee", fee, #function),
                        let royaltyFee: [String: JSONObject]? = try getOptionalJsonParameter(
                            "royaltyFee", fee, #function),
                        (fixedFee != nil && fractionalFee == nil && royaltyFee == nil)
                            || (fixedFee == nil && fractionalFee != nil && royaltyFee == nil)
                            || (fixedFee == nil && fractionalFee == nil && royaltyFee != nil)
                    else {
                        throw JSONError.invalidParams("\(#function): one and only one fee type SHALL be provided.")
                    }

                    /// Helper function for creating a FixedFee from its JSON parameters.
                    func getFixedFee(_ feeJson: [String: JSONObject]) throws -> FixedFee {
                        var tokenId: TokenId? = nil
                        if let tokenIdStr: String = try getOptionalJsonParameter(
                            "denominatingTokenId", feeJson, "createToken")
                        {
                            tokenId = try TokenId.fromString(tokenIdStr)
                        }

                        return FixedFee(
                            amount: try getRequiredJsonParameter("amount", feeJson, "createToken") as UInt64,
                            denominatingTokenId: tokenId,
                            feeCollectorAccountId: feeCollectorAccountId,
                            allCollectorsAreExempt: feeCollectorsExempt
                        )
                    }

                    if let fixedFee = fixedFee {
                        fees.append(try AnyCustomFee.fixed(getFixedFee(fixedFee)))
                    } else if let fractionalFee = fractionalFee {
                        /// Check assessmentMethod first to streamline FractionalFee construction.
                        if let assessmentMethod: String = try getOptionalJsonParameter(
                            "assessmentMethod", fractionalFee, #function)
                        {
                            guard assessmentMethod == "inclusive" || assessmentMethod == "exclusive" else {
                                throw JSONError.invalidParams(
                                    "\(#function): assessmentMethod MUST be 'inclusive' or 'exclusive'.")
                            }

                            fees.append(
                                AnyCustomFee.fractional(
                                    FractionalFee(
                                        amount: Rational<UInt64>(
                                            try getRequiredJsonParameter("numerator", fractionalFee, #function),
                                            try getRequiredJsonParameter("denominator", fractionalFee, #function)),
                                        minimumAmount: try getRequiredJsonParameter(
                                            "minimumAmount", fractionalFee, #function),
                                        maximumAmount: try getRequiredJsonParameter(
                                            "minimumAmount", fractionalFee, #function),
                                        assessmentMethod: assessmentMethod == "inclusive"
                                            ? FractionalFee.FeeAssessmentMethod.inclusive
                                            : FractionalFee.FeeAssessmentMethod.exclusive,
                                        feeCollectorAccountId: feeCollectorAccountId,
                                        allCollectorsAreExempt: feeCollectorsExempt
                                    )
                                ))
                        }
                    } else if let royaltyFee = royaltyFee {
                        var fallbackFee: FixedFee? = nil
                        if let fallbackFeeJson: [String: JSONObject] = try getOptionalJsonParameter(
                            "fallbackFee", royaltyFee, #function)
                        {
                            fallbackFee = try getFixedFee(fallbackFeeJson)
                        }

                        fees.append(
                            AnyCustomFee.royalty(
                                RoyaltyFee(
                                    numerator: try getRequiredJsonParameter("numerator", royaltyFee, #function),
                                    denominator: try getRequiredJsonParameter("denominator", royaltyFee, #function),
                                    fallbackFee: fallbackFee,
                                    feeCollectorAccountId: feeCollectorAccountId,
                                    allCollectorsAreExempt: feeCollectorsExempt
                                )
                            ))
                    }
                }
            }

            if let pauseKey: String = try getOptionalJsonParameter("pauseKey", params, #function) {
                tokenCreateTransaction.pauseKey = try getHederaKey(pauseKey)
            }

            if let metadata: String = try getOptionalJsonParameter("metadata", params, #function) {
                guard let metadataData = Data(hexEncoded: metadata) else {
                    throw JSONError.invalidParams("\(#function): metadata MUST be hex-encoded data.")
                }
                tokenCreateTransaction.metadata = metadataData
            }

            if let metadataKey: String = try getOptionalJsonParameter("metadataKey", params, #function) {
                tokenCreateTransaction.metadataKey = try getHederaKey(metadataKey)
            }

            if let commonTransactionParams: [String: JSONObject] = try getOptionalJsonParameter(
                "commonTransactionParams", params, #function)
            {
                try fillOutCommonTransactionParameters(
                    &tokenCreateTransaction, params: commonTransactionParams, client: self.client, function: #function
                )
            }
        }

        let txReceipt = try await tokenCreateTransaction.execute(client).getReceipt(client)
        return JSONObject.dictionary([
            "tokenId": JSONObject.string(txReceipt.tokenId!.toString()),
            "status": JSONObject.string(txReceipt.status.description),
        ])
    }

    internal func generateKey(_ parameters: [String: JSONObject]) throws -> JSONObject {
        var privateKeys = [JSONObject]()
        let key = try generateKeyHelper(parameters: parameters, privateKeys: &privateKeys)

        if !privateKeys.isEmpty {
            return JSONObject.dictionary(["key": JSONObject.string(key), "privateKeys": JSONObject.list(privateKeys)])
        }

        return JSONObject.dictionary(["key": JSONObject.string(key)])
    }

    internal func reset() throws -> JSONObject {
        self.client = try Client.forNetwork([String: AccountId]())
        return JSONObject.dictionary(["status": JSONObject.string("SUCCESS")])
    }

    internal func setup(_ parameters: [String: JSONObject]) throws -> JSONObject {
        let operatorAccountId = try AccountId.fromString(
            getRequiredJsonParameter("operatorAccountId", parameters, #function) as String)
        let operatorPrivateKey = try PrivateKey.fromStringDer(
            getRequiredJsonParameter("operatorPrivateKey", parameters, #function) as String)

        var clientType: String
        let nodeIp: String? = try getOptionalJsonParameter("nodeIp", parameters, #function)
        let nodeAccountId: String? = try getOptionalJsonParameter("nodeAccountId", parameters, #function)
        let mirrorNetworkIp: String? = try getOptionalJsonParameter("mirrorNetworkIp", parameters, #function)

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
