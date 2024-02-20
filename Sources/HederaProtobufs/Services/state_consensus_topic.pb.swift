// DO NOT EDIT.
// swift-format-ignore-file
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
/// First-draft representation of a Hedera Consensus Service topic in the network Merkle tree.
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
public struct Proto_Topic {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The topic's unique entity number in the Merkle state.
  public var topicNumber: Int64 = 0

  ///*
  /// The number of messages sent to the topic.
  public var sequenceNumber: Int64 = 0

  ///*
  /// The topic's consensus expiration time in seconds since the epoch.
  public var expiry: Int64 = 0

  ///*
  /// The number of seconds for which the topic will be automatically renewed
  /// upon expiring (if it has a valid auto-renew account).
  public var autoRenewPeriod: Int64 = 0

  ///*
  /// The number of the account (if any) that the network will attempt to charge for the
  /// topic's auto-renewal upon expiration.
  public var autoRenewAccountNumber: Int64 = 0

  ///*
  /// Whether this topic is deleted.
  public var deleted: Bool = false

  ///*
  /// When a topic is created, its running hash is initialized to 48 bytes of binary zeros.
  /// For each submitted message, the topic's running hash is then updated to the output
  /// of a particular SHA-384 digest whose input data include the previous running hash.
  ///
  /// See the TransactionReceipt.proto documentation for an exact description of the
  /// data included in the SHA-384 digest used for the update.
  public var runningHash: Data = Data()

  ///*
  /// An optional description of the topic with UTF-8 encoding up to 100 bytes.
  public var memo: String = String()

  ///*
  /// If present, enforces access control for updating or deleting the topic.
  /// A topic without an admin key is immutable.
  public var adminKey: Proto_Key {
    get {return _adminKey ?? Proto_Key()}
    set {_adminKey = newValue}
  }
  /// Returns true if `adminKey` has been explicitly set.
  public var hasAdminKey: Bool {return self._adminKey != nil}
  /// Clears the value of `adminKey`. Subsequent reads from it will return its default value.
  public mutating func clearAdminKey() {self._adminKey = nil}

  ///*
  /// If present, enforces access control for message submission to the topic.
  public var submitKey: Proto_Key {
    get {return _submitKey ?? Proto_Key()}
    set {_submitKey = newValue}
  }
  /// Returns true if `submitKey` has been explicitly set.
  public var hasSubmitKey: Bool {return self._submitKey != nil}
  /// Clears the value of `submitKey`. Subsequent reads from it will return its default value.
  public mutating func clearSubmitKey() {self._submitKey = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _adminKey: Proto_Key? = nil
  fileprivate var _submitKey: Proto_Key? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_Topic: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_Topic: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Topic"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "topic_number"),
    2: .standard(proto: "sequence_number"),
    3: .same(proto: "expiry"),
    4: .standard(proto: "auto_renew_period"),
    5: .standard(proto: "auto_renew_account_number"),
    6: .same(proto: "deleted"),
    7: .standard(proto: "running_hash"),
    8: .same(proto: "memo"),
    9: .standard(proto: "admin_key"),
    10: .standard(proto: "submit_key"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.topicNumber) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.sequenceNumber) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.expiry) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.autoRenewPeriod) }()
      case 5: try { try decoder.decodeSingularInt64Field(value: &self.autoRenewAccountNumber) }()
      case 6: try { try decoder.decodeSingularBoolField(value: &self.deleted) }()
      case 7: try { try decoder.decodeSingularBytesField(value: &self.runningHash) }()
      case 8: try { try decoder.decodeSingularStringField(value: &self.memo) }()
      case 9: try { try decoder.decodeSingularMessageField(value: &self._adminKey) }()
      case 10: try { try decoder.decodeSingularMessageField(value: &self._submitKey) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.topicNumber != 0 {
      try visitor.visitSingularInt64Field(value: self.topicNumber, fieldNumber: 1)
    }
    if self.sequenceNumber != 0 {
      try visitor.visitSingularInt64Field(value: self.sequenceNumber, fieldNumber: 2)
    }
    if self.expiry != 0 {
      try visitor.visitSingularInt64Field(value: self.expiry, fieldNumber: 3)
    }
    if self.autoRenewPeriod != 0 {
      try visitor.visitSingularInt64Field(value: self.autoRenewPeriod, fieldNumber: 4)
    }
    if self.autoRenewAccountNumber != 0 {
      try visitor.visitSingularInt64Field(value: self.autoRenewAccountNumber, fieldNumber: 5)
    }
    if self.deleted != false {
      try visitor.visitSingularBoolField(value: self.deleted, fieldNumber: 6)
    }
    if !self.runningHash.isEmpty {
      try visitor.visitSingularBytesField(value: self.runningHash, fieldNumber: 7)
    }
    if !self.memo.isEmpty {
      try visitor.visitSingularStringField(value: self.memo, fieldNumber: 8)
    }
    try { if let v = self._adminKey {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
    } }()
    try { if let v = self._submitKey {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_Topic, rhs: Proto_Topic) -> Bool {
    if lhs.topicNumber != rhs.topicNumber {return false}
    if lhs.sequenceNumber != rhs.sequenceNumber {return false}
    if lhs.expiry != rhs.expiry {return false}
    if lhs.autoRenewPeriod != rhs.autoRenewPeriod {return false}
    if lhs.autoRenewAccountNumber != rhs.autoRenewAccountNumber {return false}
    if lhs.deleted != rhs.deleted {return false}
    if lhs.runningHash != rhs.runningHash {return false}
    if lhs.memo != rhs.memo {return false}
    if lhs._adminKey != rhs._adminKey {return false}
    if lhs._submitKey != rhs._submitKey {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
