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
internal func getJson<T>(_ json: JSONObject, _ paramName: String, _ functionName: String) throws
    -> T
{
    if T.self == String.self {
        guard let val = json.stringValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a string.")
        }
        return val as! T
    }
    if T.self == Int32.self
    {
        guard let val = json.intValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be an int32.")
        }
        return Int32(truncatingIfNeeded: val) as! T
    }
    if T.self == UInt32.self
    {
        guard let val = json.intValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a uint32.")
        }
        return UInt32(truncatingIfNeeded: val) as! T
    }
    if T.self == Int64.self
    {
        guard let val = json.intValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be an int64.")
        }
        return val as! T
    }
    if T.self == UInt64.self
    {
        guard let val = json.intValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a uint64.")
        }
        return UInt64(truncatingIfNeeded: val) as! T
    }
    if T.self == Double.self || T.self == Float.self {
        guard let val = json.doubleValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a double.")
        }
        return val as! T
    }
    if T.self == Bool.self {
        guard let val = json.boolValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a boolean.")
        }
        return val as! T
    }
    if T.self == [JSONObject].self {
        guard let val = json.listValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a list.")
        }
        return val as! T
    }
    if T.self == [String: JSONObject].self {
        guard let val = json.dictValue else {
            throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a dictionary.")
        }
        return val as! T
    }

    throw JSONError.invalidParams("\(functionName): \(paramName) is NOT a valid type.")
}

internal func getParam(_ json: JSONObject?, _ paramName: String, _ functionName: String) throws -> JSONObject {
    return try json ?? { throw JSONError.invalidParams("\(functionName): \(paramName) MUST be provided.") }()
}

internal func getOptionalJsonParameter<T>(
    _ name: String, _ parameters: [String: JSONObject], _ functionName: String
) throws -> T? {
    guard let param = parameters[name] else {
        return nil
    }
    return try getJson(param, name, functionName) as T
}

internal func getRequiredJsonParameter<T>(
    _ name: String, _ parameters: [String: JSONObject], _ functionName: String
) throws -> T {
    return try getJson(getParam(parameters[name], name, functionName), name, functionName)
}
