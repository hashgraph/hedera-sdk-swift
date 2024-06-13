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
import Foundation
import GRPC
import HederaProtobufs
import NIO

internal class MirrorNodeGateway {
    internal var mirrorNodeUrl: String
    private let httpClient: HTTPClient

    private init(mirrorNodeUrl: String) {
        self.mirrorNodeUrl = mirrorNodeUrl
        self.httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
    }

    deinit {
        try? httpClient.syncShutdown()
    }

    internal static func forClient(_ client: Client) throws -> MirrorNodeGateway {
        let mirrorNodeUrl = try MirrorNodeRouter.getMirrorNodeUrl(client.mirrorNetwork, client.ledgerId)

        return .init(mirrorNodeUrl: mirrorNodeUrl)
    }

    internal static func forNetwork(_ mirrorNetwork: [String], _ ledgerId: LedgerId?) throws -> MirrorNodeGateway {
        let mirrorNodeUrl = try MirrorNodeRouter.getMirrorNodeUrl(mirrorNetwork, ledgerId)

        return .init(mirrorNodeUrl: mirrorNodeUrl)
    }

    internal func getAccountInfo(_ idOrAliasOrEvmAddress: String) async throws -> [String: Any] {
        let fullApiUrl = MirrorNodeRouter.buildApiUrl(
            self.mirrorNodeUrl, MirrorNodeRouter.MirrorNodeRoute.accountInfoRoute, idOrAliasOrEvmAddress)

        let responseBody = try await queryFromMirrorNode(fullApiUrl)

        let jsonObject = try await deserializeJson(responseBody)

        return jsonObject
    }

    internal func getContractInfo(_ idOrAliasOrEvmAddress: String) async throws -> [String: Any] {
        let fullApiUrl = MirrorNodeRouter.buildApiUrl(
            self.mirrorNodeUrl, MirrorNodeRouter.MirrorNodeRoute.contractInfoRoute, idOrAliasOrEvmAddress)

        let responseBody = try await queryFromMirrorNode(fullApiUrl)

        let jsonObject = try await deserializeJson(responseBody)

        return jsonObject
    }

    internal func getAccountTokens(_ idOrAliasOrEvmAddress: String) async throws -> [String: Any] {
        let fullApiUrl = MirrorNodeRouter.buildApiUrl(
            self.mirrorNodeUrl, MirrorNodeRouter.MirrorNodeRoute.tokenRelationshipsRoute, idOrAliasOrEvmAddress)

        let responseBody = try await queryFromMirrorNode(fullApiUrl)

        let jsonObject = try await deserializeJson(responseBody)

        return jsonObject
    }

    private func queryFromMirrorNode(_ apiUrl: String) async throws -> String {
        // Delay is needed to fetch data from the mirror node.
        if apiUrl.contains("127.0.0.1:5551") {
            try await Task.sleep(nanoseconds: 1_000_000_000 * 3)
        }

        let request = HTTPClientRequest(url: apiUrl)

        let response: HTTPClientResponse = try await httpClient.execute(request, timeout: .seconds(30))

        let body = try await response.body.collect(upTo: 1024 * 1024)
        let bodyString = String(decoding: body.readableBytesView, as: UTF8.self)

        return bodyString
    }

    func deserializeJson(_ responseBody: String) async throws -> [String: Any] {
        guard let jsonData = responseBody.data(using: .utf8) else {
            throw HError.mirrorNodeQuery("Response body is not valid UTF-8")
        }

        guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw HError.mirrorNodeQuery("Response body is not a valid JSON object")
        }

        return jsonObject
    }
}
