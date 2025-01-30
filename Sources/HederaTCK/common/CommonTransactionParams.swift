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

/// Struct to hold the parameters for all transactions.
internal struct CommonTransactionParams {

    internal var transactionId: String? = nil
    internal var maxTransactionFee: Int64? = nil
    internal var validTransactionDuration: Int64? = nil
    internal var memo: String? = nil
    internal var regenerateTransactionId: Bool? = nil
    internal var signers: [String]? = nil

    internal init(_ parameters: [String: JSONObject]?, _ funcName: JSONRPCMethod) throws {
        if let params = parameters {
            self.transactionId = try getOptionalJsonParameter("transactionId", params, funcName)
            self.maxTransactionFee = try getOptionalJsonParameter("maxTransactionFee", params, funcName)
            self.validTransactionDuration = try getOptionalJsonParameter("validTransactionDuration", params, funcName)
            self.memo = try getOptionalJsonParameter("memo", params, funcName)
            self.regenerateTransactionId = try getOptionalJsonParameter("regenerateTransactionId", params, funcName)
            self.signers = try (getOptionalJsonParameter("signers", params, funcName) as [JSONObject]?)?.map {
                try getJson($0, "signer in signers list", funcName) as String
            }
        }
    }
}
