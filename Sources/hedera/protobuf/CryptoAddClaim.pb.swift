// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: CryptoAddClaim.proto
//
// For information on using the generated types, please see the documenation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that your are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// A hash (presumably of some kind of credential or certificate), along with a list of keys (each of which is either a primitive or a threshold key). Each of them must reach its threshold when signing the transaction, to attach this claim to this account. At least one of them must reach its threshold to delete this Claim from this account. This is intended to provide a revocation service: all the authorities agree to attach the hash, to attest to the fact that the credential or certificate is valid. Any one of the authorities can later delete the hash, to indicate that the credential has been revoked. In this way, any client can prove to a third party that any particular account has certain credentials, or to identity facts proved about it, and that none of them have been revoked yet. 
public struct Proto_Claim {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///the account to which the claim is attached
  public var accountID: Proto_AccountID {
    get {return _storage._accountID ?? Proto_AccountID()}
    set {_uniqueStorage()._accountID = newValue}
  }
  /// Returns true if `accountID` has been explicitly set.
  public var hasAccountID: Bool {return _storage._accountID != nil}
  /// Clears the value of `accountID`. Subsequent reads from it will return its default value.
  public mutating func clearAccountID() {_uniqueStorage()._accountID = nil}

  /// 48 byte SHA-384 hash (presumably of some kind of credential or certificate)
  public var hash: Data {
    get {return _storage._hash}
    set {_uniqueStorage()._hash = newValue}
  }

  /// list of keys: all must sign the transaction to attach the claim, and any one of them can later delete it. Each "key" can actually be a threshold key containing multiple other keys (including other threshold keys).
  public var keys: Proto_KeyList {
    get {return _storage._keys ?? Proto_KeyList()}
    set {_uniqueStorage()._keys = newValue}
  }
  /// Returns true if `keys` has been explicitly set.
  public var hasKeys: Bool {return _storage._keys != nil}
  /// Clears the value of `keys`. Subsequent reads from it will return its default value.
  public mutating func clearKeys() {_uniqueStorage()._keys = nil}

  /// the duration for which the claim will remain valid
  public var claimDuration: Proto_Duration {
    get {return _storage._claimDuration ?? Proto_Duration()}
    set {_uniqueStorage()._claimDuration = newValue}
  }
  /// Returns true if `claimDuration` has been explicitly set.
  public var hasClaimDuration: Bool {return _storage._claimDuration != nil}
  /// Clears the value of `claimDuration`. Subsequent reads from it will return its default value.
  public mutating func clearClaimDuration() {_uniqueStorage()._claimDuration = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

/// Attach the given hash to the given account. The hash can be deleted by the keys used to transfer money from the account. The hash can also be deleted by any one of the deleteKeys (where that one may itself be a threshold key made up of multiple keys). Therefore, this acts as a revocation service for claims about the account. External authorities may issue certificates or credentials of some kind that make a claim about this account. The account owner can then attach a hash of that claim to the account. The transaction that adds the claim will be signed by the owner of the account, and also by all the authorities that are attesting to the truth of that claim. If the claim ever ceases to be true, such as when a certificate is revoked, then any one of the listed authorities has the ability to delete it. The account owner also has the ability to delete it at any time.
///
/// In this way, it acts as a revocation server, and the account owner can prove to any third party that the claim is still true for this account, by sending the third party the signed credential, and then having the third party query to discover whether the hash of that credential is still attached to the account.
///
/// For a given account, each Claim must contain a different hash. To modify the list of keys in a Claim, the existing Claim should first be deleted, then the Claim with the new list of keys can be added. 
public struct Proto_CryptoAddClaimTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// A hash of some credential/certificate, along with the keys that authorized it and are allowed to delete it
  public var claim: Proto_Claim {
    get {return _storage._claim ?? Proto_Claim()}
    set {_uniqueStorage()._claim = newValue}
  }
  /// Returns true if `claim` has been explicitly set.
  public var hasClaim: Bool {return _storage._claim != nil}
  /// Clears the value of `claim`. Subsequent reads from it will return its default value.
  public mutating func clearClaim() {_uniqueStorage()._claim = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_Claim: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Claim"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "accountID"),
    2: .same(proto: "hash"),
    3: .same(proto: "keys"),
    5: .same(proto: "claimDuration"),
  ]

  fileprivate class _StorageClass {
    var _accountID: Proto_AccountID? = nil
    var _hash: Data = SwiftProtobuf.Internal.emptyData
    var _keys: Proto_KeyList? = nil
    var _claimDuration: Proto_Duration? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _accountID = source._accountID
      _hash = source._hash
      _keys = source._keys
      _claimDuration = source._claimDuration
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
        switch fieldNumber {
        case 1: try decoder.decodeSingularMessageField(value: &_storage._accountID)
        case 2: try decoder.decodeSingularBytesField(value: &_storage._hash)
        case 3: try decoder.decodeSingularMessageField(value: &_storage._keys)
        case 5: try decoder.decodeSingularMessageField(value: &_storage._claimDuration)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._accountID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if !_storage._hash.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._hash, fieldNumber: 2)
      }
      if let v = _storage._keys {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
      if let v = _storage._claimDuration {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_Claim, rhs: Proto_Claim) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._accountID != rhs_storage._accountID {return false}
        if _storage._hash != rhs_storage._hash {return false}
        if _storage._keys != rhs_storage._keys {return false}
        if _storage._claimDuration != rhs_storage._claimDuration {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_CryptoAddClaimTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CryptoAddClaimTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    3: .same(proto: "claim"),
  ]

  fileprivate class _StorageClass {
    var _claim: Proto_Claim? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _claim = source._claim
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
        switch fieldNumber {
        case 3: try decoder.decodeSingularMessageField(value: &_storage._claim)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._claim {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_CryptoAddClaimTransactionBody, rhs: Proto_CryptoAddClaimTransactionBody) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._claim != rhs_storage._claim {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
