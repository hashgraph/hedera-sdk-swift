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

/// Struct to hold the parameters of a 'updateToken' JSON-RPC method call.
internal struct UpdateTokenParams {

    internal var tokenId: String? = nil
    internal var symbol: String? = nil
    internal var name: String? = nil
    internal var treasuryAccountId: String? = nil
    internal var adminKey: String? = nil
    internal var kycKey: String? = nil
    internal var freezeKey: String? = nil
    internal var wipeKey: String? = nil
    internal var supplyKey: String? = nil
    internal var autoRenewAccountId: String? = nil
    internal var autoRenewPeriod: String? = nil
    internal var expirationTime: String? = nil
    internal var memo: String? = nil
    internal var feeScheduleKey: String? = nil
    internal var pauseKey: String? = nil
    internal var metadata: String? = nil
    internal var metadataKey: String? = nil
    internal var commonTransactionParams: CommonTransactionParams? = nil

    internal init(_ request: JSONRequest) throws {
        if let params = try getOptionalParams(request) {
            self.tokenId = try getOptionalJsonParameter("tokenId", params, JSONRPCMethod.UPDATE_TOKEN)
            self.symbol = try getOptionalJsonParameter("symbol", params, JSONRPCMethod.UPDATE_TOKEN)
            self.name = try getOptionalJsonParameter("name", params, JSONRPCMethod.UPDATE_TOKEN)
            self.treasuryAccountId = try getOptionalJsonParameter(
                "treasuryAccountId", params, JSONRPCMethod.UPDATE_TOKEN)
            self.adminKey = try getOptionalJsonParameter("adminKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.kycKey = try getOptionalJsonParameter("kycKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.freezeKey = try getOptionalJsonParameter("freezeKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.wipeKey = try getOptionalJsonParameter("wipeKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.supplyKey = try getOptionalJsonParameter("supplyKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.autoRenewAccountId = try getOptionalJsonParameter(
                "autoRenewAccountId", params, JSONRPCMethod.UPDATE_TOKEN)
            self.autoRenewPeriod = try getOptionalJsonParameter("autoRenewPeriod", params, JSONRPCMethod.UPDATE_TOKEN)
            self.expirationTime = try getOptionalJsonParameter("expirationTime", params, JSONRPCMethod.UPDATE_TOKEN)
            self.memo = try getOptionalJsonParameter("memo", params, JSONRPCMethod.UPDATE_TOKEN)
            self.feeScheduleKey = try getOptionalJsonParameter("feeScheduleKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.pauseKey = try getOptionalJsonParameter("pauseKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.metadata = try getOptionalJsonParameter("metadata", params, JSONRPCMethod.UPDATE_TOKEN)
            self.metadataKey = try getOptionalJsonParameter("metadataKey", params, JSONRPCMethod.UPDATE_TOKEN)
            self.commonTransactionParams = try CommonTransactionParams(
                try getOptionalJsonParameter("commonTransactionParams", params, JSONRPCMethod.UPDATE_TOKEN),
                JSONRPCMethod.UPDATE_TOKEN)
        }
    }
}
