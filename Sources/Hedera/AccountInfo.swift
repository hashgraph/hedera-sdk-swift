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

import Foundation

// TODO: stakingInfo
/// Response from `AccountInfoQuery`.
public final class AccountInfo: Codable {
    /// The account that is being referenced.
    public let accountId: AccountId

    /// The Contract Account ID comprising of both the contract instance and the cryptocurrency
    /// account owned by the contract instance, in the format used by Solidity.
    public let contractAccountId: String

    /// If true, then this account has been deleted, it will disappear when it expires, and all
    /// transactions for it will fail except the transaction to extend its expiration date.
    public let isDeleted: Bool

    /// The total number of HBARs proxy staked to this account.
    // TODO: use Hbar type
    public let proxyReceived: UInt64

    /// The key for the account, which must sign in order to transfer out, or to modify the
    /// account in any way other than extending its expiration date.
    public let key: Key

    /// Current balance of the referenced account.
    // TODO: use Hbar type
    public let balance: UInt64

    /// If true, no transaction can transfer to this account unless signed by
    /// this account's key.
    public let isReceiverSignatureRequired: Bool

    /// The TimeStamp time at which this account is set to expire.
    public let expirationTime: Date?

    /// The duration for expiration time will extend every this many seconds.
    public let autoRenewPeriod: TimeInterval?

    /// The memo associated with the account.
    public let accountMemo: String

    /// The number of NFTs owned by this account
    public let ownedNfts: UInt64

    /// The maximum number of tokens that an Account can be implicitly associated with.
    public let maxAutomaticTokenAssociations: UInt32

    /// The alias of this account.
    public let alias: PublicKey?

    /// The ethereum transaction nonce associated with this account.
    public let ethereumNonce: UInt64
}
