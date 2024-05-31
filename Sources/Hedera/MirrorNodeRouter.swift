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

import AsyncHTTPClient
import Atomics
import Foundation
import GRPC
import HederaProtobufs
import NIOCore

internal struct MirrorNodeRouter {
    static let apiVersion: String = "/api/v1"

    static let localNodePort = "5551"

    public static let accountsRoute = "accounts"
    public static let contractsRoute = "contracts"
    public static let accountTokensRoute = "account_tokens"

    static let routes: [String: String] = [
        accountsRoute: "/accounts/%@",
        contractsRoute: "/contracts/%@",
        accountTokensRoute: "/accounts/%@/tokens",
    ]

    private func MirrorNodeRouter() {}

    static func getMirrorNodeUrl(_ mirrorNetwork: [String], _ ledgerId: LedgerId?) throws -> String {
        var mirrorNodeAddress: String = ""

        mirrorNetwork
            .map { address in
                address.prefix { $0 != ":" }
            }
            .first.map { mirrorNodeAddress = String($0) }!

        var fullMirrorNodeUrl: String

        if ledgerId != nil {
            fullMirrorNodeUrl = String("https://\(mirrorNodeAddress)")
        } else {
            fullMirrorNodeUrl = String("http://\(mirrorNodeAddress):\(localNodePort)")
        }

        return fullMirrorNodeUrl
    }

    static func buildApiUrl(_ mirrorNodeUrl: String, _ route: String, _ id: String) -> String {
        return String("\(mirrorNodeUrl)\(apiVersion)\(String(format: "\(String(describing: routes[route]!))", id))")
    }
}
