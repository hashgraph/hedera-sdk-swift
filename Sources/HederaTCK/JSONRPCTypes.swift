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

private let jsonrpcVersion = "2.0"

internal struct JSONRequest: Codable {
    let jsonrpc: String
    var id: Int
    var method: String
    var params: JSONObject?

    init(id: Int, method: String, params: JSONObject) {
        self.jsonrpc = jsonrpcVersion
        self.id = id
        self.method = method
        self.params = params
    }
}

internal struct JSONResponse: Codable, ResponseEncodable {
    let jsonrpc: String
    var id: Int
    var result: JSONObject?
    var error: JSONError?

    init(id: Int, result: JSONObject) {
        self.jsonrpc = jsonrpcVersion
        self.id = id
        self.result = result
        self.error = nil
    }

    init(id: Int, error: JSONError) {
        self.jsonrpc = jsonrpcVersion
        self.id = id
        self.result = nil
        self.error = error
    }

    init(id: Int, errorCode: JSONErrorCode, error: Error) {
        self.init(id: id, error: JSONError(code: errorCode, error: error))
    }

    init(id: Int, result: RPCObject) {
        self.init(id: id, result: JSONObject(result))
    }

    init(id: Int, error: RPCError) {
        self.init(id: id, error: JSONError(error))
    }
    
    func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        do {
            let response = Response(status: .ok)
            try response.content.encode(self, as: .json)
            return request.eventLoop.makeSucceededFuture(response)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
}

internal struct JSONError: Codable {
    var code: Int
    var message: String
    var data: Dictionary<String, String>?

    init(code: Int, message: String) {
        self.code = code
        self.message = message
        self.data = nil
    }

    init(code: JSONErrorCode, message: String) {
        self.init(code: code.rawValue, message: message)
    }

    init(code: JSONErrorCode, error: Error) {
        self.init(code: code, message: String(describing: error))
    }

    init(_ error: RPCError) {
        switch error.kind {
        case .invalidMethod:
            self.init(code: .methodNotFound, message: error.description ?? "invalid method")
        case .invalidParams:
            self.init(code: .invalidParams, message: error.description ?? "invalid params")
        case .invalidRequest:
            self.init(code: .invalidRequest, message: error.description ?? "invalid request")
        case .applicationError(let description):
            self.init(code: .other, message: error.description ?? description)
        }
    }
}

internal enum JSONErrorCode: Int, Codable {
    case parseError = -32700
    case invalidRequest = -32600
    case methodNotFound = -32601
    case invalidParams = -32602
    case internalError = -32603
    case other = -32000
}

internal enum JSONObject: Codable {
    case none
    case string(String)
    case integer(Int)
    case double(Double)
    case bool(Bool)
    case list([JSONObject])
    case dictionary([String: JSONObject])

    init(_ object: RPCObject) {
        switch object {
        case .none:
            self = .none
        case .string(let value):
            self = .string(value)
        case .integer(let value):
            self = .integer(value)
        case .double(let value):
            self = .double(value)
        case .bool(let value):
            self = .bool(value)
        case .list(let value):
            self = .list(value.map { JSONObject($0) })
        case .dictionary(let value):
            self = .dictionary(value.mapValues { JSONObject($0) })
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .integer(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode([JSONObject].self) {
            self = .list(value)
        } else if let value = try? container.decode([String: JSONObject].self) {
            self = .dictionary(value)
        } else {
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .none:
            break
        case .string(let value):
            try container.encode(value)
        case .integer(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .list(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}

public enum RPCObject: Equatable {
    case none
    case string(String)
    case integer(Int)
    case double(Double)
    case bool(Bool)
    case list([RPCObject])
    case dictionary([String: RPCObject])

    public init(_ value: String) {
        self = .string(value)
    }

    public init(_ value: Int) {
        self = .integer(value)
    }

    public init(_ value: Double) {
        self = .double(value)
    }

    public init(_ value: Bool) {
        self = .bool(value)
    }

    public init(_ value: [String]) {
        self = .list(value.map { RPCObject($0) })
    }

    public init(_ value: [Int]) {
        self = .list(value.map { RPCObject($0) })
    }

    public init(_ value: [String: String]) {
        self = .dictionary(value.mapValues { RPCObject($0) })
    }

    public init(_ value: [String: Int]) {
        self = .dictionary(value.mapValues { RPCObject($0) })
    }

    public init(_ value: [RPCObject]) {
        self = .list(value)
    }

    internal init(_ object: JSONObject) {
        switch object {
        case .none:
            self = .none
        case .string(let value):
            self = .string(value)
        case .integer(let value):
            self = .integer(value)
        case .double(let value):
            self = .double(value)
        case .bool(let value):
            self = .bool(value)
        case .list(let value):
            self = .list(value.map { RPCObject($0) })
        case .dictionary(let value):
            self = .dictionary(value.mapValues { RPCObject($0) })
        }
    }
}

public struct RPCError {
    public init(_ kind: Kind, description: String? = nil) {
        self.kind = kind
        self.description = description
    }

    public let kind: Kind
    public let description: String?

    public enum Kind {
        case invalidMethod
        case invalidParams(String)
        case invalidRequest(String)
        case applicationError(String)
    }
}

