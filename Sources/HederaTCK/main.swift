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

private func encodeJsonRpcResponseToHttpResponse(jsonResponse: JSONResponse) throws -> Response {
    let responseData = try JSONEncoder().encode(jsonResponse)
    return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(data: responseData))
}

struct TCKServer {
    var sdkClient: SDKClient

    static func main() throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let app = Application(env)
        defer { app.shutdown() }

        app.http.server.configuration.port = 80
        app.post { req -> Response in
            var jsonRpcRequest: JSONRequest
            do {
                jsonRpcRequest = try req.content.decode(JSONRequest.self)
            } catch let error as JSONError {
                return try encodeJsonRpcResponseToHttpResponse(jsonResponse: JSONResponse(id: nil, error: error))
            }

            /// The request is well-formed, it can be processed.
            return try encodeJsonRpcResponseToHttpResponse(jsonResponse: server.processRequest(request: jsonRpcRequest))
        }

        try app.run()
    }

    func processRequest(request: JSONRequest) -> JSONResponse {
        do {
            switch request.method {
            ///
            /// generateKey
            ///
            case "generateKey":
                return JSONResponse(id: request.id, result: try sdkClient.generateKey(parameters: request.params))
            ///
            /// reset
            ///
            case "reset":
                return JSONResponse(id: request.id, result: try sdkClient.reset())
            ///
            /// setup
            ///
            case "setup":
                return JSONResponse(id: request.id, result: try sdkClient.setup(parameters: request.params))
            ///
            /// Method Not Found
            ///
            default:
                throw JSONError.methodNotFound("\(request.method) not implemented.")
            }
        } catch let error as JSONError {
            return JSONResponse(id: request.id, error: error)
        } catch let error as HError {
            return JSONResponse(id: request.id, error: JSONError.hederaError(error.description))
        } catch let error {
            return JSONResponse(id: request.id, error: JSONError.internalError("\(error)"))
        }
    }
}
