// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: FileCreate.proto
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

/// Create a new file, containing the given contents.  It is referenced by its FileID, and does not have a filename, so it is important to get the FileID. After the file is created, the FileID for it can be found in the receipt, or retrieved with a GetByKey query, or by asking for a Record of the transaction to be created, and retrieving that.
///
/// The file contains the given contents (possibly empty). The file will automatically disappear at the fileExpirationTime, unless its expiration is extended by another transaction before that time. If the file is deleted, then its contents will become empty and it will be marked as deleted until it expires, and then it will cease to exist. See FileGetInfoQuery for more information about files.
///
/// The keys field is a list of keys. All the keys on the list must sign to create or modify a file, but only one of them needs to sign in order to delete the file.  Each of those "keys" may itself be threshold key containing other keys (including other threshold keys). In other words, the behavior is an AND for create/modify, OR for delete. This is useful for acting as a revocation server. If it is desired to have the behavior be AND for all 3 operations (or OR for all 3), then the list should have only a single Key, which is a threshold key, with N=1 for OR, N=M for AND.
///
/// If a file is created without ANY keys in the keys field, the file is immutable ONLY the expirationTime of the file can be changed using FileUpdate API. The file contents or its keys cannot be changed.
///
/// An entity (account, file, or smart contract instance) must be created in a particular realm. If the realmID is left null, then a new realm will be created with the given admin key. If a new realm has a null adminKey, then anyone can create/modify/delete entities in that realm. But if an admin key is given, then any transaction to create/modify/delete an entity in that realm must be signed by that key, though anyone can still call functions on smart contract instances that exist in that realm. A realm ceases to exist when everything within it has expired and no longer exists.
///
/// The current API ignores shardID, realmID, and newRealmAdminKey, and creates everything in shard 0 and realm 0, with a null key. Future versions of the API will support multiple realms and multiple shards.
public struct Proto_FileCreateTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The time at which this file should expire (unless FileUpdateTransaction is used before then to extend its life)
  public var expirationTime: Proto_Timestamp {
    get {return _storage._expirationTime ?? Proto_Timestamp()}
    set {_uniqueStorage()._expirationTime = newValue}
  }
  /// Returns true if `expirationTime` has been explicitly set.
  public var hasExpirationTime: Bool {return _storage._expirationTime != nil}
  /// Clears the value of `expirationTime`. Subsequent reads from it will return its default value.
  public mutating func clearExpirationTime() {_uniqueStorage()._expirationTime = nil}

  /// All these keys must sign to create or modify the file. Any one of them can sign to delete the file.
  public var keys: Proto_KeyList {
    get {return _storage._keys ?? Proto_KeyList()}
    set {_uniqueStorage()._keys = newValue}
  }
  /// Returns true if `keys` has been explicitly set.
  public var hasKeys: Bool {return _storage._keys != nil}
  /// Clears the value of `keys`. Subsequent reads from it will return its default value.
  public mutating func clearKeys() {_uniqueStorage()._keys = nil}

  /// The bytes that are the contents of the file
  public var contents: Data {
    get {return _storage._contents}
    set {_uniqueStorage()._contents = newValue}
  }

  /// Shard in which this file is created
  public var shardID: Proto_ShardID {
    get {return _storage._shardID ?? Proto_ShardID()}
    set {_uniqueStorage()._shardID = newValue}
  }
  /// Returns true if `shardID` has been explicitly set.
  public var hasShardID: Bool {return _storage._shardID != nil}
  /// Clears the value of `shardID`. Subsequent reads from it will return its default value.
  public mutating func clearShardID() {_uniqueStorage()._shardID = nil}

  /// The Realm in which to the file is created (leave this null to create a new realm)
  public var realmID: Proto_RealmID {
    get {return _storage._realmID ?? Proto_RealmID()}
    set {_uniqueStorage()._realmID = newValue}
  }
  /// Returns true if `realmID` has been explicitly set.
  public var hasRealmID: Bool {return _storage._realmID != nil}
  /// Clears the value of `realmID`. Subsequent reads from it will return its default value.
  public mutating func clearRealmID() {_uniqueStorage()._realmID = nil}

  /// If realmID is null, then this the admin key for the new realm that will be created
  public var newRealmAdminKey: Proto_Key {
    get {return _storage._newRealmAdminKey ?? Proto_Key()}
    set {_uniqueStorage()._newRealmAdminKey = newValue}
  }
  /// Returns true if `newRealmAdminKey` has been explicitly set.
  public var hasNewRealmAdminKey: Bool {return _storage._newRealmAdminKey != nil}
  /// Clears the value of `newRealmAdminKey`. Subsequent reads from it will return its default value.
  public mutating func clearNewRealmAdminKey() {_uniqueStorage()._newRealmAdminKey = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_FileCreateTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileCreateTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    2: .same(proto: "expirationTime"),
    3: .same(proto: "keys"),
    4: .same(proto: "contents"),
    5: .same(proto: "shardID"),
    6: .same(proto: "realmID"),
    7: .same(proto: "newRealmAdminKey"),
  ]

  fileprivate class _StorageClass {
    var _expirationTime: Proto_Timestamp? = nil
    var _keys: Proto_KeyList? = nil
    var _contents: Data = SwiftProtobuf.Internal.emptyData
    var _shardID: Proto_ShardID? = nil
    var _realmID: Proto_RealmID? = nil
    var _newRealmAdminKey: Proto_Key? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _expirationTime = source._expirationTime
      _keys = source._keys
      _contents = source._contents
      _shardID = source._shardID
      _realmID = source._realmID
      _newRealmAdminKey = source._newRealmAdminKey
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
        case 2: try decoder.decodeSingularMessageField(value: &_storage._expirationTime)
        case 3: try decoder.decodeSingularMessageField(value: &_storage._keys)
        case 4: try decoder.decodeSingularBytesField(value: &_storage._contents)
        case 5: try decoder.decodeSingularMessageField(value: &_storage._shardID)
        case 6: try decoder.decodeSingularMessageField(value: &_storage._realmID)
        case 7: try decoder.decodeSingularMessageField(value: &_storage._newRealmAdminKey)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._expirationTime {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
      if let v = _storage._keys {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      }
      if !_storage._contents.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._contents, fieldNumber: 4)
      }
      if let v = _storage._shardID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
      }
      if let v = _storage._realmID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      }
      if let v = _storage._newRealmAdminKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 7)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_FileCreateTransactionBody, rhs: Proto_FileCreateTransactionBody) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._expirationTime != rhs_storage._expirationTime {return false}
        if _storage._keys != rhs_storage._keys {return false}
        if _storage._contents != rhs_storage._contents {return false}
        if _storage._shardID != rhs_storage._shardID {return false}
        if _storage._realmID != rhs_storage._realmID {return false}
        if _storage._newRealmAdminKey != rhs_storage._newRealmAdminKey {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
