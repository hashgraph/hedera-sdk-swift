// SPDX-License-Identifier: Apache-2.0
import Hedera

/// Class used to hold functions that get Hiero parameters from JSON-RPC parameters.
internal class CommonParams {

    /// Get an account ID from an optional JSON-RPC parameter.
    static internal func getAccountId(_ param: String?) throws -> AccountId? {
        return try param.flatMap { try AccountId.fromString($0) }
    }

    /// Get an amount from an optional JSON-RPC parameter.
    static internal func getAmount(_ param: String?, _ funcName: JSONRPCMethod) throws -> UInt64? {
        return try param.flatMap { try toInt($0, "amount", funcName) }
    }

    /// Get an auto renew period from an optional JSON-RPC parameter.
    static internal func getAutoRenewPeriod(_ param: String?, _ funcName: JSONRPCMethod) throws -> Duration? {
        return try param.flatMap { Duration(seconds: toUint64(try toInt($0, "autoRenewPeriod", funcName))) }
    }

    /// Get a list of custom fees from an optional JSON-RPC parameter.
    static internal func getCustomFees(_ param: [CustomFee]?, _ funcName: JSONRPCMethod) throws -> [Hedera
        .AnyCustomFee]?
    {
        return try param?.map { try $0.toHederaCustomFee(funcName) }
    }

    /// Get a denominator value from a required JSON-RPC parameter.
    static internal func getDenominator(_ param: String, _ funcName: JSONRPCMethod) throws -> Int64 {
        return try toInt(param, "denominator", funcName)
    }

    /// Get an expiration time from an optional JSON-RPC parameter.
    static internal func getExpirationTime(_ param: String?, _ funcName: JSONRPCMethod) throws -> Timestamp? {
        return try param.flatMap {
            Timestamp(seconds: toUint64(try toInt($0, "expirationTime", funcName)), subSecondNanos: 0)
        }
    }

    /// Get a Hiero Key from an optional JSON-RPC parameter.
    static internal func getKey(_ param: String?) throws -> Hedera.Key? {
        return try param.flatMap { try KeyService.service.getHieroKey($0) }
    }

    /// Get a numerator value from a required JSON-RPC parameter.
    static internal func getNumerator(_ param: String, _ funcName: JSONRPCMethod) throws -> Int64 {
        return try toInt(param, "numerator", funcName)
    }

    /// Get a staked node ID from an optional JSON-RPC parameter.
    static internal func getStakedNodeId(_ param: String?, _ funcName: JSONRPCMethod) throws -> UInt64? {
        try param.flatMap { toUint64(try toInt($0, "stakedNodeId", funcName)) }
    }

    /// Get a token ID from an optional JSON-RPC parameter.
    static internal func getTokenId(_ param: String?) throws -> TokenId? {
        try param.flatMap { try TokenId.fromString($0) }
    }

    /// Get a list of token IDs from an optional JSON-RPC parameter.
    static internal func getTokenIdList(_ param: [String]?) throws -> [TokenId]? {
        return try param?.map { try TokenId.fromString($0) }
    }

    /// Get an Int64 value from an optional JSON-RPC parameter and trunacate it to a UInt64.
    static internal func getSdkUInt64(_ param: String?, _ name: String, _ funcName: JSONRPCMethod) throws -> UInt64? {
        return try param.flatMap { toUint64(try toInt($0, name, funcName)) }
    }
}
