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
import NIO
import Foundation
import HederaProtobufs
import AsyncHTTPClient

internal final class MirrorNodeGateway {
    internal var mirrorNodeUrl: String

    private init(mirrorNodeUrl: String) {
        self.mirrorNodeUrl = mirrorNodeUrl
    }
    
    internal static func forClient(client: Client) throws -> MirrorNodeGateway {
        let mirrorNodeUrl = try MirrorNodeRouter.getMirrorNodeUrl(client.mirrorNetwork, client.ledgerId)
        
        return .init(mirrorNodeUrl: mirrorNodeUrl)
    }
    
    internal static func forNetwork(_ mirrorNetwork: [String], _ ledgerId: LedgerId?) throws -> MirrorNodeGateway {
        let mirrorNodeUrl = try MirrorNodeRouter.getMirrorNodeUrl(mirrorNetwork, ledgerId)
        
        return .init(mirrorNodeUrl: mirrorNodeUrl)
    }
    
    internal func getAccountInfo(_ idOrAliasOrEvmAddress: String) async throws -> [String: Any] {
        var fullApiUrl = MirrorNodeRouter.buildApiUrl(self.mirrorNodeUrl, MirrorNodeRouter.ACCOUNTS_ROUTE, idOrAliasOrEvmAddress)
        
        let responseBody = try await queryFromMirrorNode(fullApiUrl)
        
        guard let jsonData = responseBody.data(using: .utf8) else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response body is not valid UTF-8"])
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response body is not a valid JSON object"])
        }
        
        return jsonObject
    }
    
    internal func getContractInfo(_ idOrAliasOrEvmAddress: String) async throws -> [String: Any] {
        var fullApiUrl = MirrorNodeRouter.buildApiUrl(self.mirrorNodeUrl, MirrorNodeRouter.CONTRACTS_ROUTE, idOrAliasOrEvmAddress)
        
        let responseBody = try await queryFromMirrorNode(fullApiUrl)
        
        guard let jsonData = responseBody.data(using: .utf8) else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response body is not valid UTF-8"])
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response body is not a valid JSON object"])
        }
        
        return jsonObject
    }
    
    internal func getAccountTokens(_ idOrAliasOrEvmAddress: String) async throws -> [String: Any] {
        var fullApiUrl = MirrorNodeRouter.buildApiUrl(self.mirrorNodeUrl, MirrorNodeRouter.ACCOUNTS_ROUTE, idOrAliasOrEvmAddress)
        
        let responseBody = try await queryFromMirrorNode(fullApiUrl)
        
        guard let jsonData = responseBody.data(using: .utf8) else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response body is not valid UTF-8"])
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw NSError(domain: "InvalidResponseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Response body is not a valid JSON object"])
        }
        
        return jsonObject
    }
    
    internal func queryFromMirrorNode(_ apiUrl: String) async throws -> String {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer {
            try? httpClient.syncShutdown()
        }

        var request = HTTPClientRequest(url: apiUrl)
        request.method = .GET

        let response = try await httpClient.execute(request, timeout: .seconds(30))
    
        let body = try await response.body.collect(upTo: 1024 * 1024)
        let bodyString = String(decoding: body.readableBytesView, as: UTF8.self)
        
        return bodyString
    }
}


