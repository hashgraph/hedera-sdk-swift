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
import Hedera
import Vapor

let server = TCKServer(sdkClient: SDKClient())
try TCKServer.main()

struct TCKServer {
    var sdkClient: SDKClient

    static func main() throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        app.http.server.configuration.port = 80
        // app.logger.logLevel = .trace
        app.post { req -> EventLoopFuture<JSONResponse> in
            let jsonRpcRequest = try req.content.decode(JSONRequest.self)
            let jsonRpcResponse = try server.processRequest(jsonRpcRequest)
            return req.eventLoop.makeSucceededFuture(jsonRpcResponse)
        }

        try app.run()
    }

    func processRequest(_ request: JSONRequest) throws -> JSONResponse {
        switch request.method {
        case "setup":
            if let params = request.params, case .dictionary(let dict) = params,
            let operatorAccountId = dict["operatorAccountId"], case .string(let accountId) = operatorAccountId,
            let operatorPrivateKey = dict["operatorPrivateKey"], case .string(let privateKey) = operatorPrivateKey {
                if let nodeIp = dict["nodeIp"], case .string(let ip) = nodeIp,
                   let nodeAccountId = dict["nodeAccountId"], case .string(let accountId) = nodeAccountId,
                   let mirrorNetworkIp = dict["mirrorNetworkIp"], case .string(let mirrorIp) = mirrorNetworkIp {
                    return JSONResponse(id: request.id, result: try sdkClient.setup(operatorAccountId: accountId,
                                                                                    operatorPrivateKey: privateKey,
                                                                                    nodeIp: ip,
                                                                                    nodeAccountId: accountId,
                                                                                    mirrorNetworkIp: mirrorIp))
                   } else {
                    return JSONResponse(id: request.id, result: try sdkClient.setup(operatorAccountId: accountId,
                                                                                    operatorPrivateKey: privateKey))
                   }
            } else {
                let error = JSONError(code: -32602, message: "Invalid params")
                return JSONResponse(id: request.id, error: error)
            }
        case "reset":
            return JSONResponse(id: request.id, result: try sdkClient.reset())
        default:
            let error = JSONError(code: -32601, message: "Method not found")
            return JSONResponse(id: request.id, error: error)
        }
    }
}