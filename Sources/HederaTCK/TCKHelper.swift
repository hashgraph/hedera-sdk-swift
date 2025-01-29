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

/// Fill in a Transaction's commpon parameters based on JSON input.
internal func fillOutCommonTransactionParameters<T: Transaction>(
    _ transaction: inout T, params: [String: JSONObject], client: Client, function: String
)
    throws
{
    if let transactionId: String = try getOptionalJsonParameter("transactionId", params, function) {
        transaction.transactionId = try TransactionId.fromString(transactionId)
    }

    if let maxTransactionFee: Int64 = try getOptionalJsonParameter("maxTransactionFee", params, function) {
        transaction.maxTransactionFee = Hbar.fromTinybars(maxTransactionFee)
    }

    if let validTransactionDuration: UInt64 = try getOptionalJsonParameter(
        "validTransactionDuration", params, function)
    {
        transaction.transactionValidDuration = Duration(seconds: validTransactionDuration)
    }

    if let memo: String = try getOptionalJsonParameter("memo", params, function) {
        transaction.transactionMemo = memo
    }

    if let regenerateTransactionId: Bool = try getOptionalJsonParameter("regenerateTransactionId", params, function) {
        transaction.regenerateTransactionId = regenerateTransactionId
    }

    if let signers: [JSONObject] = try getOptionalJsonParameter("signers", params, function) {
        try transaction.freezeWith(client)
        for signer in signers {
            transaction.sign(
                try PrivateKey.fromStringDer(getJson(signer, "signers list element", "generateKey") as String))
        }
    }
}

/// Convert a String to an integer type.
internal func toInt<T: FixedWidthInteger>(_ str: String, _ parameterName: String, _ functionName: String) throws -> T {
    guard let int = T(str) else {
        throw JSONError.invalidParams("\(functionName): \(parameterName) isn't a valid \(T.self).")
    }
    return int
}

/// Convert an Int64 to a UInt64. Useful if the TCK test specification defines an Int64, but the associated SDK value is a UInt64.
internal func toUint64(_ int: Int64) -> UInt64 {
    return UInt64(truncatingIfNeeded: int)
}
