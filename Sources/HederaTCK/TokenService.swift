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

internal class TokenService {
    static let service = TokenService()

    ////////////////
    /// INTERNAL ///
    ///////////////

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

            if let initialSupply: String = try getOptionalJsonParameter("initialSupply", params, #function) {
                tokenCreateTransaction.initialSupply = toUint64(try toInt(initialSupply, "initialSupply", #function))
            }

            if let treasuryAccountId: String = try getOptionalJsonParameter("treasuryAccountId", params, #function) {
                tokenCreateTransaction.treasuryAccountId = try AccountId.fromString(treasuryAccountId)
            }

            if let adminKey: String = try getOptionalJsonParameter("adminKey", params, #function) {
                tokenCreateTransaction.adminKey = try KeyService.service.getHederaKey(adminKey)
            }

            if let kycKey: String = try getOptionalJsonParameter("kycKey", params, #function) {
                tokenCreateTransaction.kycKey = try KeyService.service.getHederaKey(kycKey)
            }

            if let freezeKey: String = try getOptionalJsonParameter("freezeKey", params, #function) {
                tokenCreateTransaction.freezeKey = try KeyService.service.getHederaKey(freezeKey)
            }

            if let wipeKey: String = try getOptionalJsonParameter("wipeKey", params, #function) {
                tokenCreateTransaction.wipeKey = try KeyService.service.getHederaKey(wipeKey)
            }

            if let supplyKey: String = try getOptionalJsonParameter("supplyKey", params, #function) {
                tokenCreateTransaction.supplyKey = try KeyService.service.getHederaKey(supplyKey)
            }

            if let freezeDefault: Bool = try getOptionalJsonParameter("freezeDefault", params, #function) {
                tokenCreateTransaction.freezeDefault = freezeDefault
            }

            if let expirationTime: String = try getOptionalJsonParameter("expirationTime", params, #function) {
                tokenCreateTransaction.expirationTime = Timestamp(
                    seconds: toUint64(try toInt(expirationTime, "expirationTime", #function)), subSecondNanos: 0)
            }

            if let autoRenewAccountId: String = try getOptionalJsonParameter("autoRenewAccountId", params, #function) {
                tokenCreateTransaction.autoRenewAccountId = try AccountId.fromString(autoRenewAccountId)
            }

            if let autoRenewPeriod: String = try getOptionalJsonParameter("autoRenewPeriod", params, #function) {
                tokenCreateTransaction.autoRenewPeriod = Duration(
                    seconds: toUint64(try toInt(autoRenewPeriod, "autoRenewPeriod", #function)))
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

            if let maxSupply: String = try getOptionalJsonParameter("maxSupply", params, #function) {
                tokenCreateTransaction.maxSupply = toUint64(try toInt(maxSupply, "maxSupply", #function))
            }

            if let feeScheduleKey: String = try getOptionalJsonParameter("feeScheduleKey", params, #function) {
                tokenCreateTransaction.feeScheduleKey = try KeyService.service.getHederaKey(feeScheduleKey)
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
                    let fixedFee: [String: JSONObject]? = try getOptionalJsonParameter("fixedFee", fee, #function)
                    let fractionalFee: [String: JSONObject]? = try getOptionalJsonParameter(
                        "fractionalFee", fee, #function)
                    let royaltyFee: [String: JSONObject]? = try getOptionalJsonParameter(
                        "royaltyFee", fee, #function)
                    guard
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
                            amount: toUint64(
                                try toInt(
                                    getRequiredJsonParameter("amount", feeJson, "createToken"),
                                    "amount",
                                    #function)),
                            denominatingTokenId: tokenId,
                            feeCollectorAccountId: feeCollectorAccountId,
                            allCollectorsAreExempt: feeCollectorsExempt
                        )
                    }

                    if let fixedFee = fixedFee {
                        fees.append(AnyCustomFee.fixed(try getFixedFee(fixedFee)))
                    } else if let fractionalFee = fractionalFee {
                        let assessmentMethod =
                            try getRequiredJsonParameter("assessmentMethod", fractionalFee, #function) as String
                        guard assessmentMethod == "inclusive" || assessmentMethod == "exclusive" else {
                            throw JSONError.invalidParams(
                                "\(#function): assessmentMethod MUST be 'inclusive' or 'exclusive'.")
                        }

                        fees.append(
                            AnyCustomFee.fractional(
                                FractionalFee(
                                    numerator: try toInt(
                                        getRequiredJsonParameter("numerator", fractionalFee, #function),
                                        "numerator",
                                        #function),
                                    denominator: try toInt(
                                        getRequiredJsonParameter("denominator", fractionalFee, #function),
                                        "numerator",
                                        #function),
                                    minimumAmount: try toUint64(
                                        toInt(
                                            getRequiredJsonParameter(
                                                "minimumAmount", fractionalFee, #function),
                                            "minimumAmount",
                                            #function)),
                                    maximumAmount: try toUint64(
                                        toInt(
                                            getRequiredJsonParameter(
                                                "maximumAmount", fractionalFee, #function),
                                            "maximumAmount",
                                            #function)),
                                    assessmentMethod: assessmentMethod == "inclusive"
                                        ? FractionalFee.FeeAssessmentMethod.inclusive
                                        : FractionalFee.FeeAssessmentMethod.exclusive,
                                    feeCollectorAccountId: feeCollectorAccountId,
                                    allCollectorsAreExempt: feeCollectorsExempt
                                )
                            )
                        )
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
                                    numerator: try toInt(
                                        getRequiredJsonParameter("numerator", royaltyFee, #function),
                                        "numerator",
                                        #function),
                                    denominator: try toInt(
                                        getRequiredJsonParameter("denominator", royaltyFee, #function),
                                        "denominator",
                                        #function),
                                    fallbackFee: fallbackFee,
                                    feeCollectorAccountId: feeCollectorAccountId,
                                    allCollectorsAreExempt: feeCollectorsExempt
                                )
                            )
                        )
                    }
                }

                tokenCreateTransaction.customFees = fees
            }

            if let pauseKey: String = try getOptionalJsonParameter("pauseKey", params, #function) {
                tokenCreateTransaction.pauseKey = try KeyService.service.getHederaKey(pauseKey)
            }

            if let metadata: String = try getOptionalJsonParameter("metadata", params, #function) {
                guard let metadataData = metadata.data(using: .utf8) else {
                    throw JSONError.invalidParams("\(#function): metadata MUST be a UTF-8 string.")
                }
                tokenCreateTransaction.metadata = metadataData
            }

            if let metadataKey: String = try getOptionalJsonParameter("metadataKey", params, #function) {
                tokenCreateTransaction.metadataKey = try KeyService.service.getHederaKey(metadataKey)
            }

            if let commonTransactionParams: [String: JSONObject] = try getOptionalJsonParameter(
                "commonTransactionParams", params, #function)
            {
                try fillOutCommonTransactionParameters(
                    &tokenCreateTransaction, params: commonTransactionParams, client: SDKClient.client.getClient(),
                    function: #function
                )
            }
        }

        let txReceipt = try await tokenCreateTransaction.execute(SDKClient.client.getClient()).getReceipt(
            SDKClient.client.getClient())
        return JSONObject.dictionary([
            "tokenId": JSONObject.string(txReceipt.tokenId!.toString()),
            "status": JSONObject.string(txReceipt.status.description),
        ])
    }
}
