/*
 * ‌
 * Hedera Swift SDK
 *
 * Copyright (C) 2022 - 2024 Hedera Hashgraph, LLC
 *
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
 *
 */

import Atomics
import GRPC
import NIOCore
import Foundation
import HederaProtobufs
import AsyncHTTPClient

internal final class MirrorNodeRouter {
    static let API_VERSION: String = "/api/v1"
    
    static let LOCAL_NODE_PORT = "5551"
    
    public static let ACCOUNTS_ROUTE = "accounts"
    public static let CONTRACTS_ROUTE = "contracts"
    public static let ACCOUNT_TOKENS_ROUTE = "accounts_tokens"
    
    static let routes: [String: String] = [
        ACCOUNTS_ROUTE: "/accounts/%@",
        CONTRACTS_ROUTE: "/contracts/%@",
        ACCOUNT_TOKENS_ROUTE: "/accounts/%@/tokens",
    ]
    
    private func MirrorNodeRouter() {}
    
    static func getMirrorNodeUrl(_ mirrorNetwork: [String], _ ledgerId: LedgerId?) throws -> String {
        let mirrorNodeAddress: String? = mirrorNetwork
            .map { address in
                address.prefix { $0 != ":" }
            }
            .first.map { String($0) }

        if mirrorNodeAddress == nil {
            fatalError("Mirror address not found")
        }
        
        var fullMirrorNodeUrl: String
        
        if ledgerId != nil {
            fullMirrorNodeUrl = String("http://\(mirrorNodeAddress)")
        } else {
            fullMirrorNodeUrl = String("http://\(mirrorNodeAddress):\(LOCAL_NODE_PORT)")
        }
        
        return fullMirrorNodeUrl
    }
    
    static func buildApiUrl(_ mirrorNodeUrl: String, _ route: String, _ id: String) -> String {
        return String("\(mirrorNodeUrl)\(API_VERSION)\(String(format: "\(String(describing: routes[route]))", id))")
    }
}


