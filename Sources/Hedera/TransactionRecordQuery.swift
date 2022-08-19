/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
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

/// Get the record of a transaction, given its transaction ID.
///
public final class TransactionRecordQuery: Query<TransactionRecord> {
    /// The ID of the transaction for which the record is being requested.
    // TODO: TransactionId
    public var transactionId: String?

    /// Set the ID of the transaction for which the record is being requested.
    @discardableResult
    public func transactionId(_ transactionId: String) -> Self {
        self.transactionId = transactionId

        return self
    }

    /// Whether records of processing duplicate transactions should be returned.
    public var includeDuplicates: Bool = false

    /// Sets whether records of processing duplicate transactions should be returned.
    @discardableResult
    public func includeDuplicates(_ includeDuplicates: Bool) -> Self {
        self.includeDuplicates = includeDuplicates

        return self
    }

    /// Whether the response should include the records of any child transactions spawned by the
    /// top-level transaction with the given transaction.
    public var includeChildren: Bool = false

    /// Sets whether the response should include the records of any child transactions spawned by the
    /// top-level transaction with the given transaction.
    @discardableResult
    public func includeChildren(_ includeChildren: Bool) -> Self {
        self.includeChildren = includeChildren

        return self
    }

    /// Whether the record status should be validated.
    public var validateStatus: Bool = false

    /// Sets whether the record status should be validated.
    @discardableResult
    public func validateStatus(_ validateStatus: Bool) -> Self {
        self.validateStatus = validateStatus

        return self
    }

    private enum CodingKeys: String, CodingKey {
        case transactionId
        case includeChildren
        case includeDuplicates
        case validateStatus
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(transactionId, forKey: .transactionId)
        try container.encode(includeDuplicates, forKey: .includeDuplicates)
        try container.encode(includeChildren, forKey: .includeChildren)
        try container.encode(validateStatus, forKey: .validateStatus)

        try super.encode(to: encoder)
    }
}
