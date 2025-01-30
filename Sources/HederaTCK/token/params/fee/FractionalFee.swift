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

/// Struct to hold the parameters of a fractional fee.
internal struct FractionalFee {

    internal var numerator: String
    internal var denominator: String
    internal var minimumAmount: String
    internal var maximumAmount: String
    internal var assessmentMethod: String

    internal init(_ params: [String: JSONObject], _ funcName: JSONRPCMethod) throws {
        self.numerator = try getRequiredJsonParameter("numerator", params, funcName)
        self.denominator = try getRequiredJsonParameter("denominator", params, funcName)
        self.minimumAmount = try getRequiredJsonParameter("minimumAmount", params, funcName)
        self.maximumAmount = try getRequiredJsonParameter("maximumAmount", params, funcName)
        self.assessmentMethod = try getRequiredJsonParameter("assessmentMethod", params, funcName)
    }

    /// Convert this FractionalFee to a Hedera FractionalFee.
    internal func toHederaFractionalFee(
        _ feeCollectorAccountID: AccountId, _ feeCollectorsExempt: Bool, _ funcName: JSONRPCMethod
    ) throws
        -> Hedera.FractionalFee
    {
        guard self.assessmentMethod == "inclusive" || self.assessmentMethod == "exclusive" else {
            throw JSONError.invalidParams("\(funcName.rawValue): assessmentMethod MUST be 'inclusive' or 'exclusive'.")
        }

        return Hedera.FractionalFee(
            numerator: try toInt(self.numerator, "numerator", funcName),
            denominator: try toInt(self.denominator, "denominator", funcName),
            minimumAmount: toUint64(try toInt(self.minimumAmount, "minimumAmount", funcName)),
            maximumAmount: toUint64(try toInt(self.maximumAmount, "maximumAmount", funcName)),
            assessmentMethod: self.assessmentMethod == "inclusive"
                ? Hedera.FractionalFee.FeeAssessmentMethod.inclusive
                : Hedera.FractionalFee.FeeAssessmentMethod.exclusive,
            feeCollectorAccountId: feeCollectorAccountID,
            allCollectorsAreExempt: feeCollectorsExempt
        )
    }
}
