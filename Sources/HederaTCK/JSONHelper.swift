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
internal func getJsonAsString(_ json: JSONObject, _ paramName: String, _ functionName: String) throws -> String {
    guard let str = json.stringValue else {
        throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a string.")
    }
    return str
}

internal func getJsonAsInt(_ json: JSONObject, _ paramName: String, _ functionName: String) throws -> Int64 {
    guard let param = json.intValue else {
        throw JSONError.invalidParams("\(functionName): \(paramName) MUST be an integer.")
    }
    return param
}

internal func getJsonAsDouble(_ json: JSONObject, _ paramName: String, _ functionName: String) throws -> Double {
    guard let param = json.doubleValue else {
        throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a double.")
    }
    return param
}

internal func getJsonAsBoolean(_ json: JSONObject, _ paramName: String, _ functionName: String) throws -> Bool {
    guard let param = json.boolValue else {
        throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a boolean.")
    }
    return param
}

internal func getJsonAsList(_ json: JSONObject, _ paramName: String, _ functionName: String) throws -> [JSONObject] {
    guard let param = json.listValue else {
        throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a list.")
    }
    return param
}

internal func getJsonAsDict(_ json: JSONObject, _ paramName: String, _ functionName: String) throws -> [String:
    JSONObject]
{
    guard let param = json.dictValue else {
        throw JSONError.invalidParams("\(functionName): \(paramName) MUST be a dictionary.")
    }
    return param
}

internal func getParam(_ json: JSONObject?, _ paramName: String, _ functionName: String) throws -> JSONObject {
    return try json ?? { throw JSONError.invalidParams("\(functionName): \(paramName) MUST be provided.") }()
}

internal func getOptionalStringParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws
    -> String?
{
    return parameters[name] != nil ? try getJsonAsString(parameters[name]!, name, functionName) : nil
}

internal func getOptionalIntParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws
    -> Int64?
{
    return parameters[name] != nil ? try getJsonAsInt(parameters[name]!, name, functionName) : nil
}

internal func getOptionalDoubleParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws
    -> Double?
{
    return parameters[name] != nil ? try getJsonAsDouble(parameters[name]!, name, functionName) : nil
}

internal func getOptionalBooleanParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws -> Bool?
{
    return parameters[name] != nil ? try getJsonAsBoolean(parameters[name]!, name, functionName) : nil
}

internal func getOptionalListParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws
    -> [JSONObject]?
{
    return parameters[name] != nil ? try getJsonAsList(parameters[name]!, name, functionName) : nil
}

internal func getOptionalDictParameter(
    _ name: String, _ parameters: [String: JSONObject], _ functionName: String
)
    throws -> [String: JSONObject]?
{
    return parameters[name] != nil ? try getJsonAsDict(parameters[name]!, name, functionName) : nil
}

internal func getRequiredStringParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws -> String
{
    return try getJsonAsString(getParam(parameters[name], name, functionName), name, functionName)
}

internal func getRequiredIntParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws -> Int64
{
    return try getJsonAsInt(getParam(parameters[name], name, functionName), name, functionName)
}

internal func getRequiredDoubleParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws -> Double
{
    return try getJsonAsDouble(getParam(parameters[name], name, functionName), name, functionName)
}

internal func getRequiredBooleanParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws -> Bool
{
    return try getJsonAsBoolean(getParam(parameters[name], name, functionName), name, functionName)
}

internal func getRequiredListParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws -> [JSONObject]
{
    return try getJsonAsList(getParam(parameters[name], name, functionName), name, functionName)
}

internal func getRequiredDictParameter(_ name: String, _ parameters: [String: JSONObject], _ functionName: String)
    throws -> [String: JSONObject]
{
    return try getJsonAsDict(getParam(parameters[name], name, functionName), name, functionName)
}
