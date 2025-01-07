// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: file_update.proto
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
/// Modify the metadata and/or contents of a file. If a field is not set in the transaction body, the
/// corresponding file attribute will be unchanged. This transaction must be signed by all the keys
/// in the top level of a key list (M-of-M) of the file being updated. If the keys themselves are
/// being updated, then the transaction must also be signed by all the new keys. If the keys contain
/// additional KeyList or ThresholdKey then M-of-M secondary KeyList or ThresholdKey signing
/// requirements must be meet If the update transaction sets the <tt>auto_renew_account_id</tt> field 
/// to anything other than the sentinel <tt>0.0.0</tt>, the key of the referenced account must sign.
public struct Proto_FileUpdateTransactionBody: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The ID of the file to update
  public var fileID: Proto_FileID {
    get {return _fileID ?? Proto_FileID()}
    set {_fileID = newValue}
  }
  /// Returns true if `fileID` has been explicitly set.
  public var hasFileID: Bool {return self._fileID != nil}
  /// Clears the value of `fileID`. Subsequent reads from it will return its default value.
  public mutating func clearFileID() {self._fileID = nil}

  ///*
  /// The new expiry time (ignored if not later than the current expiry)
  public var expirationTime: Proto_Timestamp {
    get {return _expirationTime ?? Proto_Timestamp()}
    set {_expirationTime = newValue}
  }
  /// Returns true if `expirationTime` has been explicitly set.
  public var hasExpirationTime: Bool {return self._expirationTime != nil}
  /// Clears the value of `expirationTime`. Subsequent reads from it will return its default value.
  public mutating func clearExpirationTime() {self._expirationTime = nil}

  ///*
  /// The new list of keys that can modify or delete the file
  public var keys: Proto_KeyList {
    get {return _keys ?? Proto_KeyList()}
    set {_keys = newValue}
  }
  /// Returns true if `keys` has been explicitly set.
  public var hasKeys: Bool {return self._keys != nil}
  /// Clears the value of `keys`. Subsequent reads from it will return its default value.
  public mutating func clearKeys() {self._keys = nil}

  ///*
  /// The new contents that should overwrite the file's current contents
  public var contents: Data = Data()

  ///*
  /// If set, the new memo to be associated with the file (UTF-8 encoding max 100 bytes)
  public var memo: SwiftProtobuf.Google_Protobuf_StringValue {
    get {return _memo ?? SwiftProtobuf.Google_Protobuf_StringValue()}
    set {_memo = newValue}
  }
  /// Returns true if `memo` has been explicitly set.
  public var hasMemo: Bool {return self._memo != nil}
  /// Clears the value of `memo`. Subsequent reads from it will return its default value.
  public mutating func clearMemo() {self._memo = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _fileID: Proto_FileID? = nil
  fileprivate var _expirationTime: Proto_Timestamp? = nil
  fileprivate var _keys: Proto_KeyList? = nil
  fileprivate var _memo: SwiftProtobuf.Google_Protobuf_StringValue? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_FileUpdateTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileUpdateTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "fileID"),
    2: .same(proto: "expirationTime"),
    3: .same(proto: "keys"),
    4: .same(proto: "contents"),
    5: .same(proto: "memo"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._fileID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._expirationTime) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._keys) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.contents) }()
      case 5: try { try decoder.decodeSingularMessageField(value: &self._memo) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._fileID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._expirationTime {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._keys {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if !self.contents.isEmpty {
      try visitor.visitSingularBytesField(value: self.contents, fieldNumber: 4)
    }
    try { if let v = self._memo {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_FileUpdateTransactionBody, rhs: Proto_FileUpdateTransactionBody) -> Bool {
    if lhs._fileID != rhs._fileID {return false}
    if lhs._expirationTime != rhs._expirationTime {return false}
    if lhs._keys != rhs._keys {return false}
    if lhs.contents != rhs.contents {return false}
    if lhs._memo != rhs._memo {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
