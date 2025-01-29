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
import Vapor

@testable import Hedera

private let server = TCKServer()
try TCKServer.main()

internal class TCKServer {

    ////////////////
    /// INTERNAL ///
    ////////////////

    internal static func main() throws {
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

            let response = await server.processRequest(request: jsonRpcRequest)
            return try encodeJsonRpcResponseToHttpResponse(
                jsonResponse: response)
        }

        try app.run()
    }

    ///////////////
    /// PRIVATE ///
    ///////////////

    /// Enumeration of currently-implemented JSON-RPC endpoints.
    private enum JSONRPCMethod: String {
        case CREATE_ACCOUNT = "createAccount"
        case CREATE_TOKEN = "createToken"
        case DELETE_ACCOUNT = "deleteAccount"
        case GENERATE_KEY = "generateKey"
        case RESET = "reset"
        case SETUP = "setup"
        case UPDATE_ACCOUNT = "updateAccount"
        case UNDEFINED_METHOD
    }

    /// Fully process a JSON-RPC request and generate a response.
    private func processRequest(request: JSONRequest) async -> JSONResponse {
        do {
            let jsonRpcResponse: JSONObject
            let method = JSONRPCMethod(rawValue: request.method) ?? JSONRPCMethod.UNDEFINED_METHOD

            switch method {
            ///
            /// AccountService JSON-RPC methods.
            ///
            case JSONRPCMethod.CREATE_ACCOUNT:
                jsonRpcResponse = try await AccountService.service.createAccount(getOptionalParams(request))
            case JSONRPCMethod.DELETE_ACCOUNT:
                jsonRpcResponse = try await AccountService.service.deleteAccount(getOptionalParams(request))
            case JSONRPCMethod.UPDATE_ACCOUNT:
                jsonRpcResponse = try await AccountService.service.updateAccount(getOptionalParams(request))
            ///
            /// KeyService JSON-RPC methods.
            ///
            case JSONRPCMethod.GENERATE_KEY:
                jsonRpcResponse = try KeyService.service.generateKey(getRequiredParams(request))
            ///
            /// SdkClient JSON-RPC methods.
            ///
            case JSONRPCMethod.RESET:
                jsonRpcResponse = try SDKClient.client.reset()
            case JSONRPCMethod.SETUP:
                jsonRpcResponse = try SDKClient.client.setup(getRequiredParams(request))
            ///
            /// TokenService JSON-RPC methods.
            ///
            case JSONRPCMethod.CREATE_TOKEN:
                jsonRpcResponse = try await TokenService.service.createToken(getOptionalParams(request))
            ///
            /// Undefined method or method not provided.
            ///
            case JSONRPCMethod.UNDEFINED_METHOD:
                throw JSONError.methodNotFound("\(request.method) not implemented.")
            }

            return JSONResponse(id: request.id, result: jsonRpcResponse)

        } catch let error as JSONError {
            return JSONResponse(id: request.id, error: error)
        } catch let error as HError {
            switch error.kind {
            case .transactionPreCheckStatus(let status, _),
                .queryPreCheckStatus(let status, _),
                .receiptStatus(let status, _):
                return JSONResponse(
                    id: request.id,
                    error: JSONError.hederaError(
                        "Hedera error",
                        JSONObject.dictionary([
                            "status": JSONObject.string(Status.nameMap[status.rawValue]!),
                            "message": JSONObject.string(error.description),
                        ])))
            default:
                print(error)
                return JSONResponse(id: request.id, error: JSONError.internalError("\(error)"))
            }
        } catch let error {
            print(error)
            return JSONResponse(id: request.id, error: JSONError.internalError("\(error)"))
        }
    }

    /// Get the JSON-RPC request parameters that are required.
    private func getRequiredParams(_ request: JSONRequest) throws -> [String: JSONObject] {
        return try getRequiredJsonParameter("params", request.toDict(), request.method)
    }

    /// Get the JSON-RPC request parameters that are optional.
    private func getOptionalParams(_ request: JSONRequest) throws -> [String: JSONObject]? {
        return try getOptionalJsonParameter("params", request.toDict(), request.method)
    }

    /// Fills an HTTP response with a JSON-RPC response.
    private static func encodeJsonRpcResponseToHttpResponse(jsonResponse: JSONResponse) throws -> Response {
        let responseData = try JSONEncoder().encode(jsonResponse)
        return Response(status: .ok, headers: ["Content-Type": "application/json"], body: .init(data: responseData))
    }
}
