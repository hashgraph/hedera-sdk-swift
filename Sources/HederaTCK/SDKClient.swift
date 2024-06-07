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
import Hedera

class SDKClient {
    var client: Client

    init() {
        self.client = Client.forTestnet()
    }

    func setup(operatorAccountId: String, operatorPrivateKey: String, nodeIp: String? = nil, nodeAccountId: String? = nil, mirrorNetworkIp: String? = nil) throws -> JSONObject {
        var clientType: String

        if let ip = nodeIp, let accountId = nodeAccountId, let mirrorIp = mirrorNetworkIp {
            self.client = try Client.forNetwork([ip : AccountId.fromString(accountId)])
            self.client.setMirrorNetwork([mirrorIp])
            clientType = "custom"
        }
        else {
            self.client = Client.forTestnet()
            clientType = "testnet"
        }

        try self.client.setOperator(AccountId.fromString(operatorAccountId), PrivateKey.fromStringDer(operatorPrivateKey))

        return JSONObject.dictionary(["message": JSONObject.string("Successfully setup " + clientType + " client."),
                                      "success": JSONObject.string("SUCCESS")])
                                              
    }

    func reset() throws -> JSONObject {
        self.client = try Client.forNetwork([String: AccountId]())
        return JSONObject.dictionary(["status": JSONObject.string("SUCCESS")])                                              
    }
}