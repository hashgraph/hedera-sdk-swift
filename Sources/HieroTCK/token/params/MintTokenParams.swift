/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2025 Hiero LLC
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

/// Struct to hold the parameters of a 'mintToken' JSON-RPC method call.
internal struct MintTokenParams {

    internal var tokenId: String? = nil
    internal var amount: String? = nil
    internal var metadata: [String]? = nil
    internal var commonTransactionParams: CommonTransactionParams? = nil

    internal init(_ request: JSONRequest) throws {
        if let params = try getOptionalParams(request) {
            self.tokenId = try getOptionalJsonParameter("tokenId", params, JSONRPCMethod.mintToken)
            self.amount = try getOptionalJsonParameter("amount", params, JSONRPCMethod.mintToken)
            self.metadata = try
                (getOptionalJsonParameter("metadata", params, JSONRPCMethod.mintToken) as [JSONObject]?)?.map {
                    try getJson($0, "metadata in metadata list", JSONRPCMethod.mintToken)
                }
            self.commonTransactionParams = try CommonTransactionParams(
                try getOptionalJsonParameter("commonTransactionParams", params, JSONRPCMethod.mintToken),
                JSONRPCMethod.mintToken)
        }
    }
}
