// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: crypto_update.proto
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
/// Change properties for the given account. Any null field is ignored (left unchanged). This
/// transaction must be signed by the existing key for this account. If the transaction is changing
/// the key field, then the transaction must be signed by both the old key (from before the change)
/// and the new key. The old key must sign for security. The new key must sign as a safeguard to
/// avoid accidentally changing to an invalid key, and then having no way to recover.
/// If the update transaction sets the <tt>auto_renew_account</tt> field to anything other
/// than the sentinel <tt>0.0.0</tt>, the key of the referenced account must sign.
public struct Proto_CryptoUpdateTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The account ID which is being updated in this transaction
  public var accountIdtoUpdate: Proto_AccountID {
    get {return _storage._accountIdtoUpdate ?? Proto_AccountID()}
    set {_uniqueStorage()._accountIdtoUpdate = newValue}
  }
  /// Returns true if `accountIdtoUpdate` has been explicitly set.
  public var hasAccountIdtoUpdate: Bool {return _storage._accountIdtoUpdate != nil}
  /// Clears the value of `accountIdtoUpdate`. Subsequent reads from it will return its default value.
  public mutating func clearAccountIdtoUpdate() {_uniqueStorage()._accountIdtoUpdate = nil}

  ///*
  /// The new key
  public var key: Proto_Key {
    get {return _storage._key ?? Proto_Key()}
    set {_uniqueStorage()._key = newValue}
  }
  /// Returns true if `key` has been explicitly set.
  public var hasKey: Bool {return _storage._key != nil}
  /// Clears the value of `key`. Subsequent reads from it will return its default value.
  public mutating func clearKey() {_uniqueStorage()._key = nil}

  ///*
  /// [Deprecated] ID of the account to which this account is proxy staked. If proxyAccountID is null, or is an
  /// invalid account, or is an account that isn't a node, then this account is automatically proxy
  /// staked to a node chosen by the network, but without earning payments. If the proxyAccountID
  /// account refuses to accept proxy staking , or if it is not currently running a node, then it
  /// will behave as if proxyAccountID was null.
  public var proxyAccountID: Proto_AccountID {
    get {return _storage._proxyAccountID ?? Proto_AccountID()}
    set {_uniqueStorage()._proxyAccountID = newValue}
  }
  /// Returns true if `proxyAccountID` has been explicitly set.
  public var hasProxyAccountID: Bool {return _storage._proxyAccountID != nil}
  /// Clears the value of `proxyAccountID`. Subsequent reads from it will return its default value.
  public mutating func clearProxyAccountID() {_uniqueStorage()._proxyAccountID = nil}

  ///*
  /// [Deprecated]. Payments earned from proxy staking are shared between the node and this
  /// account, with proxyFraction / 10000 going to this account
  public var proxyFraction: Int32 {
    get {return _storage._proxyFraction}
    set {_uniqueStorage()._proxyFraction = newValue}
  }

  public var sendRecordThresholdField: OneOf_SendRecordThresholdField? {
    get {return _storage._sendRecordThresholdField}
    set {_uniqueStorage()._sendRecordThresholdField = newValue}
  }

  ///*
  /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
  /// created for any send/withdraw transaction
  public var sendRecordThreshold: UInt64 {
    get {
      if case .sendRecordThreshold(let v)? = _storage._sendRecordThresholdField {return v}
      return 0
    }
    set {_uniqueStorage()._sendRecordThresholdField = .sendRecordThreshold(newValue)}
  }

  ///*
  /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
  /// created for any send/withdraw transaction
  public var sendRecordThresholdWrapper: SwiftProtobuf.Google_Protobuf_UInt64Value {
    get {
      if case .sendRecordThresholdWrapper(let v)? = _storage._sendRecordThresholdField {return v}
      return SwiftProtobuf.Google_Protobuf_UInt64Value()
    }
    set {_uniqueStorage()._sendRecordThresholdField = .sendRecordThresholdWrapper(newValue)}
  }

  public var receiveRecordThresholdField: OneOf_ReceiveRecordThresholdField? {
    get {return _storage._receiveRecordThresholdField}
    set {_uniqueStorage()._receiveRecordThresholdField = newValue}
  }

  ///*
  /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
  /// created for any receive/deposit transaction.
  public var receiveRecordThreshold: UInt64 {
    get {
      if case .receiveRecordThreshold(let v)? = _storage._receiveRecordThresholdField {return v}
      return 0
    }
    set {_uniqueStorage()._receiveRecordThresholdField = .receiveRecordThreshold(newValue)}
  }

  ///*
  /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
  /// created for any receive/deposit transaction.
  public var receiveRecordThresholdWrapper: SwiftProtobuf.Google_Protobuf_UInt64Value {
    get {
      if case .receiveRecordThresholdWrapper(let v)? = _storage._receiveRecordThresholdField {return v}
      return SwiftProtobuf.Google_Protobuf_UInt64Value()
    }
    set {_uniqueStorage()._receiveRecordThresholdField = .receiveRecordThresholdWrapper(newValue)}
  }

  ///*
  /// The duration in which it will automatically extend the expiration period. If it doesn't have
  /// enough balance, it extends as long as possible. If it is empty when it expires, then it is
  /// deleted.
  public var autoRenewPeriod: Proto_Duration {
    get {return _storage._autoRenewPeriod ?? Proto_Duration()}
    set {_uniqueStorage()._autoRenewPeriod = newValue}
  }
  /// Returns true if `autoRenewPeriod` has been explicitly set.
  public var hasAutoRenewPeriod: Bool {return _storage._autoRenewPeriod != nil}
  /// Clears the value of `autoRenewPeriod`. Subsequent reads from it will return its default value.
  public mutating func clearAutoRenewPeriod() {_uniqueStorage()._autoRenewPeriod = nil}

  ///*
  /// The new expiration time to extend to (ignored if equal to or before the current one)
  public var expirationTime: Proto_Timestamp {
    get {return _storage._expirationTime ?? Proto_Timestamp()}
    set {_uniqueStorage()._expirationTime = newValue}
  }
  /// Returns true if `expirationTime` has been explicitly set.
  public var hasExpirationTime: Bool {return _storage._expirationTime != nil}
  /// Clears the value of `expirationTime`. Subsequent reads from it will return its default value.
  public mutating func clearExpirationTime() {_uniqueStorage()._expirationTime = nil}

  public var receiverSigRequiredField: OneOf_ReceiverSigRequiredField? {
    get {return _storage._receiverSigRequiredField}
    set {_uniqueStorage()._receiverSigRequiredField = newValue}
  }

  ///*
  /// [Deprecated] Do NOT use this field to set a false value because the server cannot
  /// distinguish from the default value. Use receiverSigRequiredWrapper field for this
  /// purpose.
  public var receiverSigRequired: Bool {
    get {
      if case .receiverSigRequired(let v)? = _storage._receiverSigRequiredField {return v}
      return false
    }
    set {_uniqueStorage()._receiverSigRequiredField = .receiverSigRequired(newValue)}
  }

  ///*
  /// If true, this account's key must sign any transaction depositing into this account (in
  /// addition to all withdrawals)
  public var receiverSigRequiredWrapper: SwiftProtobuf.Google_Protobuf_BoolValue {
    get {
      if case .receiverSigRequiredWrapper(let v)? = _storage._receiverSigRequiredField {return v}
      return SwiftProtobuf.Google_Protobuf_BoolValue()
    }
    set {_uniqueStorage()._receiverSigRequiredField = .receiverSigRequiredWrapper(newValue)}
  }

  ///*
  /// If set, the new memo to be associated with the account (UTF-8 encoding max 100 bytes)
  public var memo: SwiftProtobuf.Google_Protobuf_StringValue {
    get {return _storage._memo ?? SwiftProtobuf.Google_Protobuf_StringValue()}
    set {_uniqueStorage()._memo = newValue}
  }
  /// Returns true if `memo` has been explicitly set.
  public var hasMemo: Bool {return _storage._memo != nil}
  /// Clears the value of `memo`. Subsequent reads from it will return its default value.
  public mutating func clearMemo() {_uniqueStorage()._memo = nil}

  ///*
  /// If set, modify the maximum number of tokens that can be auto-associated with the
  /// account.<br/>
  /// If this is set and less than or equal to `used_auto_associations`, or 0, then this account
  /// MUST manually associate with a token before transacting in that token.<br/>
  /// This value MAY also be `-1` to indicate no limit.<br/>
  /// This value MUST NOT be less than `-1`.
  public var maxAutomaticTokenAssociations: SwiftProtobuf.Google_Protobuf_Int32Value {
    get {return _storage._maxAutomaticTokenAssociations ?? SwiftProtobuf.Google_Protobuf_Int32Value()}
    set {_uniqueStorage()._maxAutomaticTokenAssociations = newValue}
  }
  /// Returns true if `maxAutomaticTokenAssociations` has been explicitly set.
  public var hasMaxAutomaticTokenAssociations: Bool {return _storage._maxAutomaticTokenAssociations != nil}
  /// Clears the value of `maxAutomaticTokenAssociations`. Subsequent reads from it will return its default value.
  public mutating func clearMaxAutomaticTokenAssociations() {_uniqueStorage()._maxAutomaticTokenAssociations = nil}

  ///*
  /// ID of the account or node to which this account is staking.
  public var stakedID: OneOf_StakedID? {
    get {return _storage._stakedID}
    set {_uniqueStorage()._stakedID = newValue}
  }

  ///*
  /// ID of the new account to which this account is staking. If set to the sentinel <tt>0.0.0</tt> AccountID,
  /// this field removes this account's staked account ID.
  public var stakedAccountID: Proto_AccountID {
    get {
      if case .stakedAccountID(let v)? = _storage._stakedID {return v}
      return Proto_AccountID()
    }
    set {_uniqueStorage()._stakedID = .stakedAccountID(newValue)}
  }

  ///*
  /// ID of the new node this account is staked to. If set to the sentinel <tt>-1</tt>, this field
  /// removes this account's staked node ID.
  public var stakedNodeID: Int64 {
    get {
      if case .stakedNodeID(let v)? = _storage._stakedID {return v}
      return 0
    }
    set {_uniqueStorage()._stakedID = .stakedNodeID(newValue)}
  }

  ///*
  /// If true, the account declines receiving a staking reward. The default value is false.
  public var declineReward: SwiftProtobuf.Google_Protobuf_BoolValue {
    get {return _storage._declineReward ?? SwiftProtobuf.Google_Protobuf_BoolValue()}
    set {_uniqueStorage()._declineReward = newValue}
  }
  /// Returns true if `declineReward` has been explicitly set.
  public var hasDeclineReward: Bool {return _storage._declineReward != nil}
  /// Clears the value of `declineReward`. Subsequent reads from it will return its default value.
  public mutating func clearDeclineReward() {_uniqueStorage()._declineReward = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_SendRecordThresholdField: Equatable {
    ///*
    /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
    /// created for any send/withdraw transaction
    case sendRecordThreshold(UInt64)
    ///*
    /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
    /// created for any send/withdraw transaction
    case sendRecordThresholdWrapper(SwiftProtobuf.Google_Protobuf_UInt64Value)

  #if !swift(>=4.1)
    public static func ==(lhs: Proto_CryptoUpdateTransactionBody.OneOf_SendRecordThresholdField, rhs: Proto_CryptoUpdateTransactionBody.OneOf_SendRecordThresholdField) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.sendRecordThreshold, .sendRecordThreshold): return {
        guard case .sendRecordThreshold(let l) = lhs, case .sendRecordThreshold(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.sendRecordThresholdWrapper, .sendRecordThresholdWrapper): return {
        guard case .sendRecordThresholdWrapper(let l) = lhs, case .sendRecordThresholdWrapper(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public enum OneOf_ReceiveRecordThresholdField: Equatable {
    ///*
    /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
    /// created for any receive/deposit transaction.
    case receiveRecordThreshold(UInt64)
    ///*
    /// [Deprecated]. The new threshold amount (in tinybars) for which an account record is
    /// created for any receive/deposit transaction.
    case receiveRecordThresholdWrapper(SwiftProtobuf.Google_Protobuf_UInt64Value)

  #if !swift(>=4.1)
    public static func ==(lhs: Proto_CryptoUpdateTransactionBody.OneOf_ReceiveRecordThresholdField, rhs: Proto_CryptoUpdateTransactionBody.OneOf_ReceiveRecordThresholdField) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.receiveRecordThreshold, .receiveRecordThreshold): return {
        guard case .receiveRecordThreshold(let l) = lhs, case .receiveRecordThreshold(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.receiveRecordThresholdWrapper, .receiveRecordThresholdWrapper): return {
        guard case .receiveRecordThresholdWrapper(let l) = lhs, case .receiveRecordThresholdWrapper(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public enum OneOf_ReceiverSigRequiredField: Equatable {
    ///*
    /// [Deprecated] Do NOT use this field to set a false value because the server cannot
    /// distinguish from the default value. Use receiverSigRequiredWrapper field for this
    /// purpose.
    case receiverSigRequired(Bool)
    ///*
    /// If true, this account's key must sign any transaction depositing into this account (in
    /// addition to all withdrawals)
    case receiverSigRequiredWrapper(SwiftProtobuf.Google_Protobuf_BoolValue)

  #if !swift(>=4.1)
    public static func ==(lhs: Proto_CryptoUpdateTransactionBody.OneOf_ReceiverSigRequiredField, rhs: Proto_CryptoUpdateTransactionBody.OneOf_ReceiverSigRequiredField) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.receiverSigRequired, .receiverSigRequired): return {
        guard case .receiverSigRequired(let l) = lhs, case .receiverSigRequired(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.receiverSigRequiredWrapper, .receiverSigRequiredWrapper): return {
        guard case .receiverSigRequiredWrapper(let l) = lhs, case .receiverSigRequiredWrapper(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  ///*
  /// ID of the account or node to which this account is staking.
  public enum OneOf_StakedID: Equatable {
    ///*
    /// ID of the new account to which this account is staking. If set to the sentinel <tt>0.0.0</tt> AccountID,
    /// this field removes this account's staked account ID.
    case stakedAccountID(Proto_AccountID)
    ///*
    /// ID of the new node this account is staked to. If set to the sentinel <tt>-1</tt>, this field
    /// removes this account's staked node ID.
    case stakedNodeID(Int64)

  #if !swift(>=4.1)
    public static func ==(lhs: Proto_CryptoUpdateTransactionBody.OneOf_StakedID, rhs: Proto_CryptoUpdateTransactionBody.OneOf_StakedID) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.stakedAccountID, .stakedAccountID): return {
        guard case .stakedAccountID(let l) = lhs, case .stakedAccountID(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.stakedNodeID, .stakedNodeID): return {
        guard case .stakedNodeID(let l) = lhs, case .stakedNodeID(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_CryptoUpdateTransactionBody: @unchecked Sendable {}
extension Proto_CryptoUpdateTransactionBody.OneOf_SendRecordThresholdField: @unchecked Sendable {}
extension Proto_CryptoUpdateTransactionBody.OneOf_ReceiveRecordThresholdField: @unchecked Sendable {}
extension Proto_CryptoUpdateTransactionBody.OneOf_ReceiverSigRequiredField: @unchecked Sendable {}
extension Proto_CryptoUpdateTransactionBody.OneOf_StakedID: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_CryptoUpdateTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CryptoUpdateTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    2: .same(proto: "accountIDToUpdate"),
    3: .same(proto: "key"),
    4: .same(proto: "proxyAccountID"),
    5: .same(proto: "proxyFraction"),
    6: .same(proto: "sendRecordThreshold"),
    11: .same(proto: "sendRecordThresholdWrapper"),
    7: .same(proto: "receiveRecordThreshold"),
    12: .same(proto: "receiveRecordThresholdWrapper"),
    8: .same(proto: "autoRenewPeriod"),
    9: .same(proto: "expirationTime"),
    10: .same(proto: "receiverSigRequired"),
    13: .same(proto: "receiverSigRequiredWrapper"),
    14: .same(proto: "memo"),
    15: .standard(proto: "max_automatic_token_associations"),
    16: .standard(proto: "staked_account_id"),
    17: .standard(proto: "staked_node_id"),
    18: .standard(proto: "decline_reward"),
  ]

  fileprivate class _StorageClass {
    var _accountIdtoUpdate: Proto_AccountID? = nil
    var _key: Proto_Key? = nil
    var _proxyAccountID: Proto_AccountID? = nil
    var _proxyFraction: Int32 = 0
    var _sendRecordThresholdField: Proto_CryptoUpdateTransactionBody.OneOf_SendRecordThresholdField?
    var _receiveRecordThresholdField: Proto_CryptoUpdateTransactionBody.OneOf_ReceiveRecordThresholdField?
    var _autoRenewPeriod: Proto_Duration? = nil
    var _expirationTime: Proto_Timestamp? = nil
    var _receiverSigRequiredField: Proto_CryptoUpdateTransactionBody.OneOf_ReceiverSigRequiredField?
    var _memo: SwiftProtobuf.Google_Protobuf_StringValue? = nil
    var _maxAutomaticTokenAssociations: SwiftProtobuf.Google_Protobuf_Int32Value? = nil
    var _stakedID: Proto_CryptoUpdateTransactionBody.OneOf_StakedID?
    var _declineReward: SwiftProtobuf.Google_Protobuf_BoolValue? = nil

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
      _accountIdtoUpdate = source._accountIdtoUpdate
      _key = source._key
      _proxyAccountID = source._proxyAccountID
      _proxyFraction = source._proxyFraction
      _sendRecordThresholdField = source._sendRecordThresholdField
      _receiveRecordThresholdField = source._receiveRecordThresholdField
      _autoRenewPeriod = source._autoRenewPeriod
      _expirationTime = source._expirationTime
      _receiverSigRequiredField = source._receiverSigRequiredField
      _memo = source._memo
      _maxAutomaticTokenAssociations = source._maxAutomaticTokenAssociations
      _stakedID = source._stakedID
      _declineReward = source._declineReward
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
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._accountIdtoUpdate) }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._key) }()
        case 4: try { try decoder.decodeSingularMessageField(value: &_storage._proxyAccountID) }()
        case 5: try { try decoder.decodeSingularInt32Field(value: &_storage._proxyFraction) }()
        case 6: try {
          var v: UInt64?
          try decoder.decodeSingularUInt64Field(value: &v)
          if let v = v {
            if _storage._sendRecordThresholdField != nil {try decoder.handleConflictingOneOf()}
            _storage._sendRecordThresholdField = .sendRecordThreshold(v)
          }
        }()
        case 7: try {
          var v: UInt64?
          try decoder.decodeSingularUInt64Field(value: &v)
          if let v = v {
            if _storage._receiveRecordThresholdField != nil {try decoder.handleConflictingOneOf()}
            _storage._receiveRecordThresholdField = .receiveRecordThreshold(v)
          }
        }()
        case 8: try { try decoder.decodeSingularMessageField(value: &_storage._autoRenewPeriod) }()
        case 9: try { try decoder.decodeSingularMessageField(value: &_storage._expirationTime) }()
        case 10: try {
          var v: Bool?
          try decoder.decodeSingularBoolField(value: &v)
          if let v = v {
            if _storage._receiverSigRequiredField != nil {try decoder.handleConflictingOneOf()}
            _storage._receiverSigRequiredField = .receiverSigRequired(v)
          }
        }()
        case 11: try {
          var v: SwiftProtobuf.Google_Protobuf_UInt64Value?
          var hadOneofValue = false
          if let current = _storage._sendRecordThresholdField {
            hadOneofValue = true
            if case .sendRecordThresholdWrapper(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._sendRecordThresholdField = .sendRecordThresholdWrapper(v)
          }
        }()
        case 12: try {
          var v: SwiftProtobuf.Google_Protobuf_UInt64Value?
          var hadOneofValue = false
          if let current = _storage._receiveRecordThresholdField {
            hadOneofValue = true
            if case .receiveRecordThresholdWrapper(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._receiveRecordThresholdField = .receiveRecordThresholdWrapper(v)
          }
        }()
        case 13: try {
          var v: SwiftProtobuf.Google_Protobuf_BoolValue?
          var hadOneofValue = false
          if let current = _storage._receiverSigRequiredField {
            hadOneofValue = true
            if case .receiverSigRequiredWrapper(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._receiverSigRequiredField = .receiverSigRequiredWrapper(v)
          }
        }()
        case 14: try { try decoder.decodeSingularMessageField(value: &_storage._memo) }()
        case 15: try { try decoder.decodeSingularMessageField(value: &_storage._maxAutomaticTokenAssociations) }()
        case 16: try {
          var v: Proto_AccountID?
          var hadOneofValue = false
          if let current = _storage._stakedID {
            hadOneofValue = true
            if case .stakedAccountID(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._stakedID = .stakedAccountID(v)
          }
        }()
        case 17: try {
          var v: Int64?
          try decoder.decodeSingularInt64Field(value: &v)
          if let v = v {
            if _storage._stakedID != nil {try decoder.handleConflictingOneOf()}
            _storage._stakedID = .stakedNodeID(v)
          }
        }()
        case 18: try { try decoder.decodeSingularMessageField(value: &_storage._declineReward) }()
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
      try { if let v = _storage._accountIdtoUpdate {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      try { if let v = _storage._key {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      } }()
      try { if let v = _storage._proxyAccountID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      } }()
      if _storage._proxyFraction != 0 {
        try visitor.visitSingularInt32Field(value: _storage._proxyFraction, fieldNumber: 5)
      }
      try { if case .sendRecordThreshold(let v)? = _storage._sendRecordThresholdField {
        try visitor.visitSingularUInt64Field(value: v, fieldNumber: 6)
      } }()
      try { if case .receiveRecordThreshold(let v)? = _storage._receiveRecordThresholdField {
        try visitor.visitSingularUInt64Field(value: v, fieldNumber: 7)
      } }()
      try { if let v = _storage._autoRenewPeriod {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
      } }()
      try { if let v = _storage._expirationTime {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
      } }()
      try { if case .receiverSigRequired(let v)? = _storage._receiverSigRequiredField {
        try visitor.visitSingularBoolField(value: v, fieldNumber: 10)
      } }()
      try { if case .sendRecordThresholdWrapper(let v)? = _storage._sendRecordThresholdField {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 11)
      } }()
      try { if case .receiveRecordThresholdWrapper(let v)? = _storage._receiveRecordThresholdField {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 12)
      } }()
      try { if case .receiverSigRequiredWrapper(let v)? = _storage._receiverSigRequiredField {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 13)
      } }()
      try { if let v = _storage._memo {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 14)
      } }()
      try { if let v = _storage._maxAutomaticTokenAssociations {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      } }()
      switch _storage._stakedID {
      case .stakedAccountID?: try {
        guard case .stakedAccountID(let v)? = _storage._stakedID else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 16)
      }()
      case .stakedNodeID?: try {
        guard case .stakedNodeID(let v)? = _storage._stakedID else { preconditionFailure() }
        try visitor.visitSingularInt64Field(value: v, fieldNumber: 17)
      }()
      case nil: break
      }
      try { if let v = _storage._declineReward {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 18)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_CryptoUpdateTransactionBody, rhs: Proto_CryptoUpdateTransactionBody) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._accountIdtoUpdate != rhs_storage._accountIdtoUpdate {return false}
        if _storage._key != rhs_storage._key {return false}
        if _storage._proxyAccountID != rhs_storage._proxyAccountID {return false}
        if _storage._proxyFraction != rhs_storage._proxyFraction {return false}
        if _storage._sendRecordThresholdField != rhs_storage._sendRecordThresholdField {return false}
        if _storage._receiveRecordThresholdField != rhs_storage._receiveRecordThresholdField {return false}
        if _storage._autoRenewPeriod != rhs_storage._autoRenewPeriod {return false}
        if _storage._expirationTime != rhs_storage._expirationTime {return false}
        if _storage._receiverSigRequiredField != rhs_storage._receiverSigRequiredField {return false}
        if _storage._memo != rhs_storage._memo {return false}
        if _storage._maxAutomaticTokenAssociations != rhs_storage._maxAutomaticTokenAssociations {return false}
        if _storage._stakedID != rhs_storage._stakedID {return false}
        if _storage._declineReward != rhs_storage._declineReward {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
