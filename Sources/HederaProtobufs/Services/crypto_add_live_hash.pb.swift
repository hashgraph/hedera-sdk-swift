// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: crypto_add_live_hash.proto
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
/// A hash---presumably of some kind of credential or certificate---along with a list of keys, each
/// of which may be either a primitive or a threshold key. 
public struct Proto_LiveHash {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The account to which the livehash is attached
  public var accountID: Proto_AccountID {
    get {return _accountID ?? Proto_AccountID()}
    set {_accountID = newValue}
  }
  /// Returns true if `accountID` has been explicitly set.
  public var hasAccountID: Bool {return self._accountID != nil}
  /// Clears the value of `accountID`. Subsequent reads from it will return its default value.
  public mutating func clearAccountID() {self._accountID = nil}

  ///*
  /// The SHA-384 hash of a credential or certificate
  public var hash: Data = Data()

  ///*
  /// A list of keys (primitive or threshold), all of which must sign to attach the livehash to an account, and any one of which can later delete it.
  public var keys: Proto_KeyList {
    get {return _keys ?? Proto_KeyList()}
    set {_keys = newValue}
  }
  /// Returns true if `keys` has been explicitly set.
  public var hasKeys: Bool {return self._keys != nil}
  /// Clears the value of `keys`. Subsequent reads from it will return its default value.
  public mutating func clearKeys() {self._keys = nil}

  ///*
  /// The duration for which the livehash will remain valid
  public var duration: Proto_Duration {
    get {return _duration ?? Proto_Duration()}
    set {_duration = newValue}
  }
  /// Returns true if `duration` has been explicitly set.
  public var hasDuration: Bool {return self._duration != nil}
  /// Clears the value of `duration`. Subsequent reads from it will return its default value.
  public mutating func clearDuration() {self._duration = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _accountID: Proto_AccountID? = nil
  fileprivate var _keys: Proto_KeyList? = nil
  fileprivate var _duration: Proto_Duration? = nil
}

///*
/// At consensus, attaches the given livehash to the given account.  The hash can be deleted by the
/// key controlling the account, or by any of the keys associated to the livehash.  Hence livehashes
/// provide a revocation service for their implied credentials; for example, when an authority grants
/// a credential to the account, the account owner will cosign with the authority (or authorities) to
/// attach a hash of the credential to the account---hence proving the grant. If the credential is
/// revoked, then any of the authorities may delete it (or the account owner). In this way, the
/// livehash mechanism acts as a revocation service.  An account cannot have two identical livehashes
/// associated. To modify the list of keys in a livehash, the livehash should first be deleted, then
/// recreated with a new list of keys.
public struct Proto_CryptoAddLiveHashTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A hash of some credential or certificate, along with the keys of the entities that asserted it validity
  public var liveHash: Proto_LiveHash {
    get {return _liveHash ?? Proto_LiveHash()}
    set {_liveHash = newValue}
  }
  /// Returns true if `liveHash` has been explicitly set.
  public var hasLiveHash: Bool {return self._liveHash != nil}
  /// Clears the value of `liveHash`. Subsequent reads from it will return its default value.
  public mutating func clearLiveHash() {self._liveHash = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _liveHash: Proto_LiveHash? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_LiveHash: @unchecked Sendable {}
extension Proto_CryptoAddLiveHashTransactionBody: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_LiveHash: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".LiveHash"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "accountId"),
    2: .same(proto: "hash"),
    3: .same(proto: "keys"),
    5: .same(proto: "duration"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._accountID) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.hash) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._keys) }()
      case 5: try { try decoder.decodeSingularMessageField(value: &self._duration) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._accountID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.hash.isEmpty {
      try visitor.visitSingularBytesField(value: self.hash, fieldNumber: 2)
    }
    try { if let v = self._keys {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try { if let v = self._duration {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_LiveHash, rhs: Proto_LiveHash) -> Bool {
    if lhs._accountID != rhs._accountID {return false}
    if lhs.hash != rhs.hash {return false}
    if lhs._keys != rhs._keys {return false}
    if lhs._duration != rhs._duration {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_CryptoAddLiveHashTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CryptoAddLiveHashTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    3: .same(proto: "liveHash"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 3: try { try decoder.decodeSingularMessageField(value: &self._liveHash) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._liveHash {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_CryptoAddLiveHashTransactionBody, rhs: Proto_CryptoAddLiveHashTransactionBody) -> Bool {
    if lhs._liveHash != rhs._liveHash {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
