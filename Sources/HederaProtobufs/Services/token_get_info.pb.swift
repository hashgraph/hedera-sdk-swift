// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: token_get_info.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

///*
/// Gets information about Token instance
public struct Proto_TokenGetInfoQuery {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Standard info sent from client to node, including the signed payment, and what kind of
  /// response is requested (cost, state proof, both, or neither)
  public var header: Proto_QueryHeader {
    get {return _header ?? Proto_QueryHeader()}
    set {_header = newValue}
  }
  /// Returns true if `header` has been explicitly set.
  public var hasHeader: Bool {return self._header != nil}
  /// Clears the value of `header`. Subsequent reads from it will return its default value.
  public mutating func clearHeader() {self._header = nil}

  ///*
  /// The token for which information is requested. If invalid token is provided, INVALID_TOKEN_ID
  /// response is returned.
  public var token: Proto_TokenID {
    get {return _token ?? Proto_TokenID()}
    set {_token = newValue}
  }
  /// Returns true if `token` has been explicitly set.
  public var hasToken: Bool {return self._token != nil}
  /// Clears the value of `token`. Subsequent reads from it will return its default value.
  public mutating func clearToken() {self._token = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _header: Proto_QueryHeader? = nil
  fileprivate var _token: Proto_TokenID? = nil
}

///*
/// The metadata about a Token instance
public struct Proto_TokenInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// ID of the token instance
  public var tokenID: Proto_TokenID {
    get {return _storage._tokenID ?? Proto_TokenID()}
    set {_uniqueStorage()._tokenID = newValue}
  }
  /// Returns true if `tokenID` has been explicitly set.
  public var hasTokenID: Bool {return _storage._tokenID != nil}
  /// Clears the value of `tokenID`. Subsequent reads from it will return its default value.
  public mutating func clearTokenID() {_uniqueStorage()._tokenID = nil}

  ///*
  /// The name of the token. It is a string of ASCII only characters
  public var name: String {
    get {return _storage._name}
    set {_uniqueStorage()._name = newValue}
  }

  ///*
  /// The symbol of the token. It is a UTF-8 capitalized alphabetical string
  public var symbol: String {
    get {return _storage._symbol}
    set {_uniqueStorage()._symbol = newValue}
  }

  ///*
  /// The number of decimal places a token is divisible by. Always 0 for tokens of type
  /// NON_FUNGIBLE_UNIQUE
  public var decimals: UInt32 {
    get {return _storage._decimals}
    set {_uniqueStorage()._decimals = newValue}
  }

  ///*
  /// For tokens of type FUNGIBLE_COMMON - the total supply of tokens that are currently in
  /// circulation. For tokens of type NON_FUNGIBLE_UNIQUE - the number of NFTs created of this
  /// token instance
  public var totalSupply: UInt64 {
    get {return _storage._totalSupply}
    set {_uniqueStorage()._totalSupply = newValue}
  }

  ///*
  /// The ID of the account which is set as Treasury
  public var treasury: Proto_AccountID {
    get {return _storage._treasury ?? Proto_AccountID()}
    set {_uniqueStorage()._treasury = newValue}
  }
  /// Returns true if `treasury` has been explicitly set.
  public var hasTreasury: Bool {return _storage._treasury != nil}
  /// Clears the value of `treasury`. Subsequent reads from it will return its default value.
  public mutating func clearTreasury() {_uniqueStorage()._treasury = nil}

  ///*
  /// The key which can perform update/delete operations on the token. If empty, the token can be
  /// perceived as immutable (not being able to be updated/deleted)
  public var adminKey: Proto_Key {
    get {return _storage._adminKey ?? Proto_Key()}
    set {_uniqueStorage()._adminKey = newValue}
  }
  /// Returns true if `adminKey` has been explicitly set.
  public var hasAdminKey: Bool {return _storage._adminKey != nil}
  /// Clears the value of `adminKey`. Subsequent reads from it will return its default value.
  public mutating func clearAdminKey() {_uniqueStorage()._adminKey = nil}

  ///*
  /// The key which can grant or revoke KYC of an account for the token's transactions. If empty,
  /// KYC is not required, and KYC grant or revoke operations are not possible.
  public var kycKey: Proto_Key {
    get {return _storage._kycKey ?? Proto_Key()}
    set {_uniqueStorage()._kycKey = newValue}
  }
  /// Returns true if `kycKey` has been explicitly set.
  public var hasKycKey: Bool {return _storage._kycKey != nil}
  /// Clears the value of `kycKey`. Subsequent reads from it will return its default value.
  public mutating func clearKycKey() {_uniqueStorage()._kycKey = nil}

  ///*
  /// The key which can freeze or unfreeze an account for token transactions. If empty, freezing is
  /// not possible
  public var freezeKey: Proto_Key {
    get {return _storage._freezeKey ?? Proto_Key()}
    set {_uniqueStorage()._freezeKey = newValue}
  }
  /// Returns true if `freezeKey` has been explicitly set.
  public var hasFreezeKey: Bool {return _storage._freezeKey != nil}
  /// Clears the value of `freezeKey`. Subsequent reads from it will return its default value.
  public mutating func clearFreezeKey() {_uniqueStorage()._freezeKey = nil}

  ///*
  /// The key which can wipe token balance of an account. If empty, wipe is not possible
  public var wipeKey: Proto_Key {
    get {return _storage._wipeKey ?? Proto_Key()}
    set {_uniqueStorage()._wipeKey = newValue}
  }
  /// Returns true if `wipeKey` has been explicitly set.
  public var hasWipeKey: Bool {return _storage._wipeKey != nil}
  /// Clears the value of `wipeKey`. Subsequent reads from it will return its default value.
  public mutating func clearWipeKey() {_uniqueStorage()._wipeKey = nil}

  ///*
  /// The key which can change the supply of a token. The key is used to sign Token Mint/Burn
  /// operations
  public var supplyKey: Proto_Key {
    get {return _storage._supplyKey ?? Proto_Key()}
    set {_uniqueStorage()._supplyKey = newValue}
  }
  /// Returns true if `supplyKey` has been explicitly set.
  public var hasSupplyKey: Bool {return _storage._supplyKey != nil}
  /// Clears the value of `supplyKey`. Subsequent reads from it will return its default value.
  public mutating func clearSupplyKey() {_uniqueStorage()._supplyKey = nil}

  ///*
  /// The default Freeze status (not applicable, frozen or unfrozen) of Hedera accounts relative to
  /// this token. FreezeNotApplicable is returned if Token Freeze Key is empty. Frozen is returned
  /// if Token Freeze Key is set and defaultFreeze is set to true. Unfrozen is returned if Token
  /// Freeze Key is set and defaultFreeze is set to false
  public var defaultFreezeStatus: Proto_TokenFreezeStatus {
    get {return _storage._defaultFreezeStatus}
    set {_uniqueStorage()._defaultFreezeStatus = newValue}
  }

  ///*
  /// The default KYC status (KycNotApplicable or Revoked) of Hedera accounts relative to this
  /// token. KycNotApplicable is returned if KYC key is not set, otherwise Revoked
  public var defaultKycStatus: Proto_TokenKycStatus {
    get {return _storage._defaultKycStatus}
    set {_uniqueStorage()._defaultKycStatus = newValue}
  }

  ///*
  /// Specifies whether the token was deleted or not
  public var deleted: Bool {
    get {return _storage._deleted}
    set {_uniqueStorage()._deleted = newValue}
  }

  ///*
  /// An account which will be automatically charged to renew the token's expiration, at
  /// autoRenewPeriod interval
  public var autoRenewAccount: Proto_AccountID {
    get {return _storage._autoRenewAccount ?? Proto_AccountID()}
    set {_uniqueStorage()._autoRenewAccount = newValue}
  }
  /// Returns true if `autoRenewAccount` has been explicitly set.
  public var hasAutoRenewAccount: Bool {return _storage._autoRenewAccount != nil}
  /// Clears the value of `autoRenewAccount`. Subsequent reads from it will return its default value.
  public mutating func clearAutoRenewAccount() {_uniqueStorage()._autoRenewAccount = nil}

  ///*
  /// The interval at which the auto-renew account will be charged to extend the token's expiry
  public var autoRenewPeriod: Proto_Duration {
    get {return _storage._autoRenewPeriod ?? Proto_Duration()}
    set {_uniqueStorage()._autoRenewPeriod = newValue}
  }
  /// Returns true if `autoRenewPeriod` has been explicitly set.
  public var hasAutoRenewPeriod: Bool {return _storage._autoRenewPeriod != nil}
  /// Clears the value of `autoRenewPeriod`. Subsequent reads from it will return its default value.
  public mutating func clearAutoRenewPeriod() {_uniqueStorage()._autoRenewPeriod = nil}

  ///*
  /// The epoch second at which the token will expire
  public var expiry: Proto_Timestamp {
    get {return _storage._expiry ?? Proto_Timestamp()}
    set {_uniqueStorage()._expiry = newValue}
  }
  /// Returns true if `expiry` has been explicitly set.
  public var hasExpiry: Bool {return _storage._expiry != nil}
  /// Clears the value of `expiry`. Subsequent reads from it will return its default value.
  public mutating func clearExpiry() {_uniqueStorage()._expiry = nil}

  ///*
  /// The memo associated with the token
  public var memo: String {
    get {return _storage._memo}
    set {_uniqueStorage()._memo = newValue}
  }

  ///*
  /// The token type
  public var tokenType: Proto_TokenType {
    get {return _storage._tokenType}
    set {_uniqueStorage()._tokenType = newValue}
  }

  ///*
  /// The token supply type
  public var supplyType: Proto_TokenSupplyType {
    get {return _storage._supplyType}
    set {_uniqueStorage()._supplyType = newValue}
  }

  ///*
  /// For tokens of type FUNGIBLE_COMMON - The Maximum number of fungible tokens that can be in
  /// circulation. For tokens of type NON_FUNGIBLE_UNIQUE - the maximum number of NFTs (serial
  /// numbers) that can be in circulation
  public var maxSupply: Int64 {
    get {return _storage._maxSupply}
    set {_uniqueStorage()._maxSupply = newValue}
  }

  ///*
  /// The key which can change the custom fee schedule of the token; if not set, the fee schedule
  /// is immutable
  public var feeScheduleKey: Proto_Key {
    get {return _storage._feeScheduleKey ?? Proto_Key()}
    set {_uniqueStorage()._feeScheduleKey = newValue}
  }
  /// Returns true if `feeScheduleKey` has been explicitly set.
  public var hasFeeScheduleKey: Bool {return _storage._feeScheduleKey != nil}
  /// Clears the value of `feeScheduleKey`. Subsequent reads from it will return its default value.
  public mutating func clearFeeScheduleKey() {_uniqueStorage()._feeScheduleKey = nil}

  ///*
  /// The custom fees to be assessed during a CryptoTransfer that transfers units of this token
  public var customFees: [Proto_CustomFee] {
    get {return _storage._customFees}
    set {_uniqueStorage()._customFees = newValue}
  }

  ///*
  /// The Key which can pause and unpause the Token.
  public var pauseKey: Proto_Key {
    get {return _storage._pauseKey ?? Proto_Key()}
    set {_uniqueStorage()._pauseKey = newValue}
  }
  /// Returns true if `pauseKey` has been explicitly set.
  public var hasPauseKey: Bool {return _storage._pauseKey != nil}
  /// Clears the value of `pauseKey`. Subsequent reads from it will return its default value.
  public mutating func clearPauseKey() {_uniqueStorage()._pauseKey = nil}

  ///*
  /// Specifies whether the token is paused or not. PauseNotApplicable is returned if pauseKey is not set.
  public var pauseStatus: Proto_TokenPauseStatus {
    get {return _storage._pauseStatus}
    set {_uniqueStorage()._pauseStatus = newValue}
  }

  ///*
  /// The ledger ID the response was returned from; please see <a href="https://github.com/hashgraph/hedera-improvement-proposal/blob/master/HIP/hip-198.md">HIP-198</a> for the network-specific IDs. 
  public var ledgerID: Data {
    get {return _storage._ledgerID}
    set {_uniqueStorage()._ledgerID = newValue}
  }

  ///*
  /// Represents the metadata of the token definition.
  public var metadata: Data {
    get {return _storage._metadata}
    set {_uniqueStorage()._metadata = newValue}
  }

  ///*
  /// The key which can change the metadata of a token
  /// (token definition and individual NFTs).
  public var metadataKey: Proto_Key {
    get {return _storage._metadataKey ?? Proto_Key()}
    set {_uniqueStorage()._metadataKey = newValue}
  }
  /// Returns true if `metadataKey` has been explicitly set.
  public var hasMetadataKey: Bool {return _storage._metadataKey != nil}
  /// Clears the value of `metadataKey`. Subsequent reads from it will return its default value.
  public mutating func clearMetadataKey() {_uniqueStorage()._metadataKey = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

///*
/// Response when the client sends the node TokenGetInfoQuery
public struct Proto_TokenGetInfoResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Standard response from node to client, including the requested fields: cost, or state proof,
  /// or both, or neither
  public var header: Proto_ResponseHeader {
    get {return _header ?? Proto_ResponseHeader()}
    set {_header = newValue}
  }
  /// Returns true if `header` has been explicitly set.
  public var hasHeader: Bool {return self._header != nil}
  /// Clears the value of `header`. Subsequent reads from it will return its default value.
  public mutating func clearHeader() {self._header = nil}

  ///*
  /// The information requested about this token instance
  public var tokenInfo: Proto_TokenInfo {
    get {return _tokenInfo ?? Proto_TokenInfo()}
    set {_tokenInfo = newValue}
  }
  /// Returns true if `tokenInfo` has been explicitly set.
  public var hasTokenInfo: Bool {return self._tokenInfo != nil}
  /// Clears the value of `tokenInfo`. Subsequent reads from it will return its default value.
  public mutating func clearTokenInfo() {self._tokenInfo = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _header: Proto_ResponseHeader? = nil
  fileprivate var _tokenInfo: Proto_TokenInfo? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_TokenGetInfoQuery: @unchecked Sendable {}
extension Proto_TokenInfo: @unchecked Sendable {}
extension Proto_TokenGetInfoResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_TokenGetInfoQuery: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TokenGetInfoQuery"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "header"),
    2: .same(proto: "token"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._header) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._token) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._header {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._token {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TokenGetInfoQuery, rhs: Proto_TokenGetInfoQuery) -> Bool {
    if lhs._header != rhs._header {return false}
    if lhs._token != rhs._token {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_TokenInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TokenInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "tokenId"),
    2: .same(proto: "name"),
    3: .same(proto: "symbol"),
    4: .same(proto: "decimals"),
    5: .same(proto: "totalSupply"),
    6: .same(proto: "treasury"),
    7: .same(proto: "adminKey"),
    8: .same(proto: "kycKey"),
    9: .same(proto: "freezeKey"),
    10: .same(proto: "wipeKey"),
    11: .same(proto: "supplyKey"),
    12: .same(proto: "defaultFreezeStatus"),
    13: .same(proto: "defaultKycStatus"),
    14: .same(proto: "deleted"),
    15: .same(proto: "autoRenewAccount"),
    16: .same(proto: "autoRenewPeriod"),
    17: .same(proto: "expiry"),
    18: .same(proto: "memo"),
    19: .same(proto: "tokenType"),
    20: .same(proto: "supplyType"),
    21: .same(proto: "maxSupply"),
    22: .standard(proto: "fee_schedule_key"),
    23: .standard(proto: "custom_fees"),
    24: .standard(proto: "pause_key"),
    25: .standard(proto: "pause_status"),
    26: .standard(proto: "ledger_id"),
    27: .same(proto: "metadata"),
    28: .standard(proto: "metadata_key"),
  ]

  fileprivate class _StorageClass {
    var _tokenID: Proto_TokenID? = nil
    var _name: String = String()
    var _symbol: String = String()
    var _decimals: UInt32 = 0
    var _totalSupply: UInt64 = 0
    var _treasury: Proto_AccountID? = nil
    var _adminKey: Proto_Key? = nil
    var _kycKey: Proto_Key? = nil
    var _freezeKey: Proto_Key? = nil
    var _wipeKey: Proto_Key? = nil
    var _supplyKey: Proto_Key? = nil
    var _defaultFreezeStatus: Proto_TokenFreezeStatus = .freezeNotApplicable
    var _defaultKycStatus: Proto_TokenKycStatus = .kycNotApplicable
    var _deleted: Bool = false
    var _autoRenewAccount: Proto_AccountID? = nil
    var _autoRenewPeriod: Proto_Duration? = nil
    var _expiry: Proto_Timestamp? = nil
    var _memo: String = String()
    var _tokenType: Proto_TokenType = .fungibleCommon
    var _supplyType: Proto_TokenSupplyType = .infinite
    var _maxSupply: Int64 = 0
    var _feeScheduleKey: Proto_Key? = nil
    var _customFees: [Proto_CustomFee] = []
    var _pauseKey: Proto_Key? = nil
    var _pauseStatus: Proto_TokenPauseStatus = .pauseNotApplicable
    var _ledgerID: Data = Data()
    var _metadata: Data = Data()
    var _metadataKey: Proto_Key? = nil

    #if swift(>=5.10)
      // This property is used as the initial default value for new instances of the type.
      // The type itself is protecting the reference to its storage via CoW semantics.
      // This will force a copy to be made of this reference when the first mutation occurs;
      // hence, it is safe to mark this as `nonisolated(unsafe)`.
      static nonisolated(unsafe) let defaultInstance = _StorageClass()
    #else
      static let defaultInstance = _StorageClass()
    #endif

    private init() {}

    init(copying source: _StorageClass) {
      _tokenID = source._tokenID
      _name = source._name
      _symbol = source._symbol
      _decimals = source._decimals
      _totalSupply = source._totalSupply
      _treasury = source._treasury
      _adminKey = source._adminKey
      _kycKey = source._kycKey
      _freezeKey = source._freezeKey
      _wipeKey = source._wipeKey
      _supplyKey = source._supplyKey
      _defaultFreezeStatus = source._defaultFreezeStatus
      _defaultKycStatus = source._defaultKycStatus
      _deleted = source._deleted
      _autoRenewAccount = source._autoRenewAccount
      _autoRenewPeriod = source._autoRenewPeriod
      _expiry = source._expiry
      _memo = source._memo
      _tokenType = source._tokenType
      _supplyType = source._supplyType
      _maxSupply = source._maxSupply
      _feeScheduleKey = source._feeScheduleKey
      _customFees = source._customFees
      _pauseKey = source._pauseKey
      _pauseStatus = source._pauseStatus
      _ledgerID = source._ledgerID
      _metadata = source._metadata
      _metadataKey = source._metadataKey
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularMessageField(value: &_storage._tokenID) }()
        case 2: try { try decoder.decodeSingularStringField(value: &_storage._name) }()
        case 3: try { try decoder.decodeSingularStringField(value: &_storage._symbol) }()
        case 4: try { try decoder.decodeSingularUInt32Field(value: &_storage._decimals) }()
        case 5: try { try decoder.decodeSingularUInt64Field(value: &_storage._totalSupply) }()
        case 6: try { try decoder.decodeSingularMessageField(value: &_storage._treasury) }()
        case 7: try { try decoder.decodeSingularMessageField(value: &_storage._adminKey) }()
        case 8: try { try decoder.decodeSingularMessageField(value: &_storage._kycKey) }()
        case 9: try { try decoder.decodeSingularMessageField(value: &_storage._freezeKey) }()
        case 10: try { try decoder.decodeSingularMessageField(value: &_storage._wipeKey) }()
        case 11: try { try decoder.decodeSingularMessageField(value: &_storage._supplyKey) }()
        case 12: try { try decoder.decodeSingularEnumField(value: &_storage._defaultFreezeStatus) }()
        case 13: try { try decoder.decodeSingularEnumField(value: &_storage._defaultKycStatus) }()
        case 14: try { try decoder.decodeSingularBoolField(value: &_storage._deleted) }()
        case 15: try { try decoder.decodeSingularMessageField(value: &_storage._autoRenewAccount) }()
        case 16: try { try decoder.decodeSingularMessageField(value: &_storage._autoRenewPeriod) }()
        case 17: try { try decoder.decodeSingularMessageField(value: &_storage._expiry) }()
        case 18: try { try decoder.decodeSingularStringField(value: &_storage._memo) }()
        case 19: try { try decoder.decodeSingularEnumField(value: &_storage._tokenType) }()
        case 20: try { try decoder.decodeSingularEnumField(value: &_storage._supplyType) }()
        case 21: try { try decoder.decodeSingularInt64Field(value: &_storage._maxSupply) }()
        case 22: try { try decoder.decodeSingularMessageField(value: &_storage._feeScheduleKey) }()
        case 23: try { try decoder.decodeRepeatedMessageField(value: &_storage._customFees) }()
        case 24: try { try decoder.decodeSingularMessageField(value: &_storage._pauseKey) }()
        case 25: try { try decoder.decodeSingularEnumField(value: &_storage._pauseStatus) }()
        case 26: try { try decoder.decodeSingularBytesField(value: &_storage._ledgerID) }()
        case 27: try { try decoder.decodeSingularBytesField(value: &_storage._metadata) }()
        case 28: try { try decoder.decodeSingularMessageField(value: &_storage._metadataKey) }()
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      try { if let v = _storage._tokenID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      } }()
      if !_storage._name.isEmpty {
        try visitor.visitSingularStringField(value: _storage._name, fieldNumber: 2)
      }
      if !_storage._symbol.isEmpty {
        try visitor.visitSingularStringField(value: _storage._symbol, fieldNumber: 3)
      }
      if _storage._decimals != 0 {
        try visitor.visitSingularUInt32Field(value: _storage._decimals, fieldNumber: 4)
      }
      if _storage._totalSupply != 0 {
        try visitor.visitSingularUInt64Field(value: _storage._totalSupply, fieldNumber: 5)
      }
      try { if let v = _storage._treasury {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      } }()
      try { if let v = _storage._adminKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 7)
      } }()
      try { if let v = _storage._kycKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
      } }()
      try { if let v = _storage._freezeKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
      } }()
      try { if let v = _storage._wipeKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
      } }()
      try { if let v = _storage._supplyKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 11)
      } }()
      if _storage._defaultFreezeStatus != .freezeNotApplicable {
        try visitor.visitSingularEnumField(value: _storage._defaultFreezeStatus, fieldNumber: 12)
      }
      if _storage._defaultKycStatus != .kycNotApplicable {
        try visitor.visitSingularEnumField(value: _storage._defaultKycStatus, fieldNumber: 13)
      }
      if _storage._deleted != false {
        try visitor.visitSingularBoolField(value: _storage._deleted, fieldNumber: 14)
      }
      try { if let v = _storage._autoRenewAccount {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      } }()
      try { if let v = _storage._autoRenewPeriod {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 16)
      } }()
      try { if let v = _storage._expiry {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 17)
      } }()
      if !_storage._memo.isEmpty {
        try visitor.visitSingularStringField(value: _storage._memo, fieldNumber: 18)
      }
      if _storage._tokenType != .fungibleCommon {
        try visitor.visitSingularEnumField(value: _storage._tokenType, fieldNumber: 19)
      }
      if _storage._supplyType != .infinite {
        try visitor.visitSingularEnumField(value: _storage._supplyType, fieldNumber: 20)
      }
      if _storage._maxSupply != 0 {
        try visitor.visitSingularInt64Field(value: _storage._maxSupply, fieldNumber: 21)
      }
      try { if let v = _storage._feeScheduleKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 22)
      } }()
      if !_storage._customFees.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._customFees, fieldNumber: 23)
      }
      try { if let v = _storage._pauseKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 24)
      } }()
      if _storage._pauseStatus != .pauseNotApplicable {
        try visitor.visitSingularEnumField(value: _storage._pauseStatus, fieldNumber: 25)
      }
      if !_storage._ledgerID.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._ledgerID, fieldNumber: 26)
      }
      if !_storage._metadata.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._metadata, fieldNumber: 27)
      }
      try { if let v = _storage._metadataKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 28)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TokenInfo, rhs: Proto_TokenInfo) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._tokenID != rhs_storage._tokenID {return false}
        if _storage._name != rhs_storage._name {return false}
        if _storage._symbol != rhs_storage._symbol {return false}
        if _storage._decimals != rhs_storage._decimals {return false}
        if _storage._totalSupply != rhs_storage._totalSupply {return false}
        if _storage._treasury != rhs_storage._treasury {return false}
        if _storage._adminKey != rhs_storage._adminKey {return false}
        if _storage._kycKey != rhs_storage._kycKey {return false}
        if _storage._freezeKey != rhs_storage._freezeKey {return false}
        if _storage._wipeKey != rhs_storage._wipeKey {return false}
        if _storage._supplyKey != rhs_storage._supplyKey {return false}
        if _storage._defaultFreezeStatus != rhs_storage._defaultFreezeStatus {return false}
        if _storage._defaultKycStatus != rhs_storage._defaultKycStatus {return false}
        if _storage._deleted != rhs_storage._deleted {return false}
        if _storage._autoRenewAccount != rhs_storage._autoRenewAccount {return false}
        if _storage._autoRenewPeriod != rhs_storage._autoRenewPeriod {return false}
        if _storage._expiry != rhs_storage._expiry {return false}
        if _storage._memo != rhs_storage._memo {return false}
        if _storage._tokenType != rhs_storage._tokenType {return false}
        if _storage._supplyType != rhs_storage._supplyType {return false}
        if _storage._maxSupply != rhs_storage._maxSupply {return false}
        if _storage._feeScheduleKey != rhs_storage._feeScheduleKey {return false}
        if _storage._customFees != rhs_storage._customFees {return false}
        if _storage._pauseKey != rhs_storage._pauseKey {return false}
        if _storage._pauseStatus != rhs_storage._pauseStatus {return false}
        if _storage._ledgerID != rhs_storage._ledgerID {return false}
        if _storage._metadata != rhs_storage._metadata {return false}
        if _storage._metadataKey != rhs_storage._metadataKey {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_TokenGetInfoResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TokenGetInfoResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "header"),
    2: .same(proto: "tokenInfo"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._header) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._tokenInfo) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._header {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._tokenInfo {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TokenGetInfoResponse, rhs: Proto_TokenGetInfoResponse) -> Bool {
    if lhs._header != rhs._header {return false}
    if lhs._tokenInfo != rhs._tokenInfo {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
