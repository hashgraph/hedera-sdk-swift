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

/// Struct to hold the parameters of a 'createToken' JSON-RPC method call.
internal struct CreateTokenParams {

    internal var name: String? = nil
    internal var symbol: String? = nil
    internal var decimals: UInt32? = nil
    internal var initialSupply: String? = nil
    internal var treasuryAccountId: String? = nil
    internal var adminKey: String? = nil
    internal var kycKey: String? = nil
    internal var freezeKey: String? = nil
    internal var wipeKey: String? = nil
    internal var supplyKey: String? = nil
    internal var freezeDefault: Bool? = nil
    internal var expirationTime: String? = nil
    internal var autoRenewAccountId: String? = nil
    internal var autoRenewPeriod: String? = nil
    internal var memo: String? = nil
    internal var tokenType: String? = nil
    internal var supplyType: String? = nil
    internal var maxSupply: String? = nil
    internal var feeScheduleKey: String? = nil
    internal var customFees: [CustomFee]? = nil
    internal var pauseKey: String? = nil
    internal var metadata: String? = nil
    internal var metadataKey: String? = nil
    internal var commonTransactionParams: CommonTransactionParams? = nil

    internal init(_ request: JSONRequest) throws {
        if let params = try getOptionalParams(request) {
            self.name = try getOptionalJsonParameter("name", params, JSONRPCMethod.CREATE_TOKEN)
            self.symbol = try getOptionalJsonParameter("symbol", params, JSONRPCMethod.CREATE_TOKEN)
            self.decimals = try getOptionalJsonParameter("decimals", params, JSONRPCMethod.CREATE_TOKEN)
            self.initialSupply = try getOptionalJsonParameter("initialSupply", params, JSONRPCMethod.CREATE_TOKEN)
            self.treasuryAccountId = try getOptionalJsonParameter(
                "treasuryAccountId", params, JSONRPCMethod.CREATE_TOKEN)
            self.adminKey = try getOptionalJsonParameter("adminKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.kycKey = try getOptionalJsonParameter("kycKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.freezeKey = try getOptionalJsonParameter("freezeKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.wipeKey = try getOptionalJsonParameter("wipeKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.supplyKey = try getOptionalJsonParameter("supplyKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.freezeDefault = try getOptionalJsonParameter("freezeDefault", params, JSONRPCMethod.CREATE_TOKEN)
            self.expirationTime = try getOptionalJsonParameter("expirationTime", params, JSONRPCMethod.CREATE_TOKEN)
            self.autoRenewAccountId = try getOptionalJsonParameter(
                "autoRenewAccountId", params, JSONRPCMethod.CREATE_TOKEN)
            self.autoRenewPeriod = try getOptionalJsonParameter("autoRenewPeriod", params, JSONRPCMethod.CREATE_TOKEN)
            self.memo = try getOptionalJsonParameter("memo", params, JSONRPCMethod.CREATE_TOKEN)
            self.tokenType = try getOptionalJsonParameter("tokenType", params, JSONRPCMethod.CREATE_TOKEN)
            self.supplyType = try getOptionalJsonParameter("supplyType", params, JSONRPCMethod.CREATE_TOKEN)
            self.maxSupply = try getOptionalJsonParameter("maxSupply", params, JSONRPCMethod.CREATE_TOKEN)
            self.feeScheduleKey = try getOptionalJsonParameter("feeScheduleKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.customFees = try
                (getOptionalJsonParameter("customFees", params, JSONRPCMethod.CREATE_TOKEN) as [JSONObject]?)?
                .map {
                    try CustomFee(
                        getJson($0, "fee in custom fees list", JSONRPCMethod.CREATE_TOKEN),
                        JSONRPCMethod.CREATE_TOKEN)
                }
            self.pauseKey = try getOptionalJsonParameter("pauseKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.metadata = try getOptionalJsonParameter("metadata", params, JSONRPCMethod.CREATE_TOKEN)
            self.metadataKey = try getOptionalJsonParameter("metadataKey", params, JSONRPCMethod.CREATE_TOKEN)
            self.commonTransactionParams = try CommonTransactionParams(
                try getOptionalJsonParameter("commonTransactionParams", params, JSONRPCMethod.CREATE_TOKEN),
                JSONRPCMethod.CREATE_TOKEN)
        }
    }
}
