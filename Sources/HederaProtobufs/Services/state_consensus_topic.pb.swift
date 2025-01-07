// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: state/consensus/topic.proto
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
/// Representation of a Hedera Consensus Service topic in the network Merkle tree.
/// 
/// As with all network entities, a topic has a unique entity number, which is usually given along 
/// with the network's shard and realm in the form of a shard.realm.number id.
/// 
/// A topic consists of just two pieces of data:
///   1. The total number of messages sent to the topic; and,
///   2. The running hash of all those messages.
/// It also has several metadata elements:
///   1. A consensus expiration time in seconds since the epoch.
///   2. (Optional) The number of an auto-renew account, in the same shard and realm as the topic, that 
///   has signed a transaction allowing the network to use its balance to automatically extend the topic's 
///   expiration time when it passes.
///   3. The number of seconds the network should automatically extend the topic's expiration by, if the 
///   topic has a valid auto-renew account, and is not deleted upon expiration.
///   4. A boolean marking if the topic has been deleted.
///   5. A memo string whose UTF-8 encoding is at most 100 bytes.
///   6. (Optional) An admin key whose signature must be active for the topic's metadata to be updated.
///   7. (Optional) A submit key whose signature must be active for the topic to receive a message.
public struct Proto_Topic: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The topic's unique id in the Merkle state.
  public var topicID: Proto_TopicID {
    get {return _storage._topicID ?? Proto_TopicID()}
    set {_uniqueStorage()._topicID = newValue}
  }
  /// Returns true if `topicID` has been explicitly set.
  public var hasTopicID: Bool {return _storage._topicID != nil}
  /// Clears the value of `topicID`. Subsequent reads from it will return its default value.
  public mutating func clearTopicID() {_uniqueStorage()._topicID = nil}

  ///*
  /// The number of messages sent to the topic.
  public var sequenceNumber: Int64 {
    get {return _storage._sequenceNumber}
    set {_uniqueStorage()._sequenceNumber = newValue}
  }

  ///*
  /// The topic's consensus expiration time in seconds since the epoch.
  public var expirationSecond: Int64 {
    get {return _storage._expirationSecond}
    set {_uniqueStorage()._expirationSecond = newValue}
  }

  ///*
  /// The number of seconds for which the topic will be automatically renewed 
  /// upon expiring (if it has a valid auto-renew account).
  public var autoRenewPeriod: Int64 {
    get {return _storage._autoRenewPeriod}
    set {_uniqueStorage()._autoRenewPeriod = newValue}
  }

  ///*
  /// The id of the account (if any) that the network will attempt to charge for the
  /// topic's auto-renewal upon expiration.
  public var autoRenewAccountID: Proto_AccountID {
    get {return _storage._autoRenewAccountID ?? Proto_AccountID()}
    set {_uniqueStorage()._autoRenewAccountID = newValue}
  }
  /// Returns true if `autoRenewAccountID` has been explicitly set.
  public var hasAutoRenewAccountID: Bool {return _storage._autoRenewAccountID != nil}
  /// Clears the value of `autoRenewAccountID`. Subsequent reads from it will return its default value.
  public mutating func clearAutoRenewAccountID() {_uniqueStorage()._autoRenewAccountID = nil}

  ///*
  /// Whether this topic is deleted.
  public var deleted: Bool {
    get {return _storage._deleted}
    set {_uniqueStorage()._deleted = newValue}
  }

  ///*
  /// When a topic is created, its running hash is initialized to 48 bytes of binary zeros.
  /// For each submitted message, the topic's running hash is then updated to the output
  /// of a particular SHA-384 digest whose input data include the previous running hash.
  /// 
  /// See the TransactionReceipt.proto documentation for an exact description of the
  /// data included in the SHA-384 digest used for the update.
  public var runningHash: Data {
    get {return _storage._runningHash}
    set {_uniqueStorage()._runningHash = newValue}
  }

  ///*
  /// An optional description of the topic with UTF-8 encoding up to 100 bytes.
  public var memo: String {
    get {return _storage._memo}
    set {_uniqueStorage()._memo = newValue}
  }

  ///*
  /// If present, enforces access control for updating or deleting the topic.
  /// A topic without an admin key is immutable.
  public var adminKey: Proto_Key {
    get {return _storage._adminKey ?? Proto_Key()}
    set {_uniqueStorage()._adminKey = newValue}
  }
  /// Returns true if `adminKey` has been explicitly set.
  public var hasAdminKey: Bool {return _storage._adminKey != nil}
  /// Clears the value of `adminKey`. Subsequent reads from it will return its default value.
  public mutating func clearAdminKey() {_uniqueStorage()._adminKey = nil}

  ///*
  /// If present, enforces access control for message submission to the topic.
  public var submitKey: Proto_Key {
    get {return _storage._submitKey ?? Proto_Key()}
    set {_uniqueStorage()._submitKey = newValue}
  }
  /// Returns true if `submitKey` has been explicitly set.
  public var hasSubmitKey: Bool {return _storage._submitKey != nil}
  /// Clears the value of `submitKey`. Subsequent reads from it will return its default value.
  public mutating func clearSubmitKey() {_uniqueStorage()._submitKey = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_Topic: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Topic"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "topic_id"),
    2: .standard(proto: "sequence_number"),
    3: .standard(proto: "expiration_second"),
    4: .standard(proto: "auto_renew_period"),
    5: .standard(proto: "auto_renew_account_id"),
    6: .same(proto: "deleted"),
    7: .standard(proto: "running_hash"),
    8: .same(proto: "memo"),
    9: .standard(proto: "admin_key"),
    10: .standard(proto: "submit_key"),
  ]

  fileprivate class _StorageClass {
    var _topicID: Proto_TopicID? = nil
    var _sequenceNumber: Int64 = 0
    var _expirationSecond: Int64 = 0
    var _autoRenewPeriod: Int64 = 0
    var _autoRenewAccountID: Proto_AccountID? = nil
    var _deleted: Bool = false
    var _runningHash: Data = Data()
    var _memo: String = String()
    var _adminKey: Proto_Key? = nil
    var _submitKey: Proto_Key? = nil

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
      _topicID = source._topicID
      _sequenceNumber = source._sequenceNumber
      _expirationSecond = source._expirationSecond
      _autoRenewPeriod = source._autoRenewPeriod
      _autoRenewAccountID = source._autoRenewAccountID
      _deleted = source._deleted
      _runningHash = source._runningHash
      _memo = source._memo
      _adminKey = source._adminKey
      _submitKey = source._submitKey
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
        case 1: try { try decoder.decodeSingularMessageField(value: &_storage._topicID) }()
        case 2: try { try decoder.decodeSingularInt64Field(value: &_storage._sequenceNumber) }()
        case 3: try { try decoder.decodeSingularInt64Field(value: &_storage._expirationSecond) }()
        case 4: try { try decoder.decodeSingularInt64Field(value: &_storage._autoRenewPeriod) }()
        case 5: try { try decoder.decodeSingularMessageField(value: &_storage._autoRenewAccountID) }()
        case 6: try { try decoder.decodeSingularBoolField(value: &_storage._deleted) }()
        case 7: try { try decoder.decodeSingularBytesField(value: &_storage._runningHash) }()
        case 8: try { try decoder.decodeSingularStringField(value: &_storage._memo) }()
        case 9: try { try decoder.decodeSingularMessageField(value: &_storage._adminKey) }()
        case 10: try { try decoder.decodeSingularMessageField(value: &_storage._submitKey) }()
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
      try { if let v = _storage._topicID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      } }()
      if _storage._sequenceNumber != 0 {
        try visitor.visitSingularInt64Field(value: _storage._sequenceNumber, fieldNumber: 2)
      }
      if _storage._expirationSecond != 0 {
        try visitor.visitSingularInt64Field(value: _storage._expirationSecond, fieldNumber: 3)
      }
      if _storage._autoRenewPeriod != 0 {
        try visitor.visitSingularInt64Field(value: _storage._autoRenewPeriod, fieldNumber: 4)
      }
      try { if let v = _storage._autoRenewAccountID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
      } }()
      if _storage._deleted != false {
        try visitor.visitSingularBoolField(value: _storage._deleted, fieldNumber: 6)
      }
      if !_storage._runningHash.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._runningHash, fieldNumber: 7)
      }
      if !_storage._memo.isEmpty {
        try visitor.visitSingularStringField(value: _storage._memo, fieldNumber: 8)
      }
      try { if let v = _storage._adminKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
      } }()
      try { if let v = _storage._submitKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_Topic, rhs: Proto_Topic) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._topicID != rhs_storage._topicID {return false}
        if _storage._sequenceNumber != rhs_storage._sequenceNumber {return false}
        if _storage._expirationSecond != rhs_storage._expirationSecond {return false}
        if _storage._autoRenewPeriod != rhs_storage._autoRenewPeriod {return false}
        if _storage._autoRenewAccountID != rhs_storage._autoRenewAccountID {return false}
        if _storage._deleted != rhs_storage._deleted {return false}
        if _storage._runningHash != rhs_storage._runningHash {return false}
        if _storage._memo != rhs_storage._memo {return false}
        if _storage._adminKey != rhs_storage._adminKey {return false}
        if _storage._submitKey != rhs_storage._submitKey {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
