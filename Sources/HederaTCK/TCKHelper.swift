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
import Hedera

/// Enumeration of implemented JSON-RPC endpoints.
internal enum JSONRPCMethod: String {
    case ASSOCIATE_TOKEN = "associateToken"
    case BURN_TOKEN = "burnToken"
    case CREATE_ACCOUNT = "createAccount"
    case CREATE_TOKEN = "createToken"
    case DELETE_ACCOUNT = "deleteAccount"
    case DELETE_TOKEN = "deleteToken"
    case DISSOCIATE_TOKEN = "dissociateToken"
    case FREEZE_TOKEN = "freezeToken"
    case GENERATE_KEY = "generateKey"
    case GRANT_TOKEN_KYC = "grantTokenKyc"
    case MINT_TOKEN = "mintToken"
    case PAUSE_TOKEN = "pauseToken"
    case RESET = "reset"
    case REVOKE_TOKEN_KYC = "revokeTokenKyc"
    case SETUP = "setup"
    case UNFREEZE_TOKEN = "unfreezeToken"
    case UNPAUSE_TOKEN = "unpauseToken"
    case UPDATE_ACCOUNT = "updateAccount"
    case UPDATE_TOKEN_FEE_SCHEDULE = "updateTokenFeeSchedule"
    case UPDATE_TOKEN = "updateToken"
    case UNDEFINED_METHOD
}

/// Convert a String to an integer type.
internal func toInt<T: FixedWidthInteger>(_ str: String, _ parameterName: String, _ funcName: JSONRPCMethod) throws -> T
{
    return try T(str)
        ?? { throw JSONError.invalidParams("\(funcName.rawValue): \(parameterName) isn't a valid \(T.self).") }()
}

/// Convert an Int64 to a UInt64. Useful if the TCK test specification defines an Int64, but the associated SDK value is a UInt64.
internal func toUint64(_ int: Int64) -> UInt64 {
    return UInt64(truncatingIfNeeded: int)
}
