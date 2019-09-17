// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: FileGetContents.proto
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

/// Get the contents of a file. The content field is empty (no bytes) if the file is empty. 
public struct Proto_FileGetContentsQuery {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Standard info sent from client to node, including the signed payment, and what kind of response is requested (cost, state proof, both, or neither).
  public var header: Proto_QueryHeader {
    get {return _storage._header ?? Proto_QueryHeader()}
    set {_uniqueStorage()._header = newValue}
  }
  /// Returns true if `header` has been explicitly set.
  public var hasHeader: Bool {return _storage._header != nil}
  /// Clears the value of `header`. Subsequent reads from it will return its default value.
  public mutating func clearHeader() {_uniqueStorage()._header = nil}

  /// The file ID of the file whose contents are requested
  public var fileID: Proto_FileID {
    get {return _storage._fileID ?? Proto_FileID()}
    set {_uniqueStorage()._fileID = newValue}
  }
  /// Returns true if `fileID` has been explicitly set.
  public var hasFileID: Bool {return _storage._fileID != nil}
  /// Clears the value of `fileID`. Subsequent reads from it will return its default value.
  public mutating func clearFileID() {_uniqueStorage()._fileID = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

/// Response when the client sends the node FileGetContentsQuery 
public struct Proto_FileGetContentsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///Standard response from node to client, including the requested fields: cost, or state proof, or both, or neither
  public var header: Proto_ResponseHeader {
    get {return _storage._header ?? Proto_ResponseHeader()}
    set {_uniqueStorage()._header = newValue}
  }
  /// Returns true if `header` has been explicitly set.
  public var hasHeader: Bool {return _storage._header != nil}
  /// Clears the value of `header`. Subsequent reads from it will return its default value.
  public mutating func clearHeader() {_uniqueStorage()._header = nil}

  /// the file ID and contents (a state proof can be generated for this)
  public var fileContents: Proto_FileGetContentsResponse.FileContents {
    get {return _storage._fileContents ?? Proto_FileGetContentsResponse.FileContents()}
    set {_uniqueStorage()._fileContents = newValue}
  }
  /// Returns true if `fileContents` has been explicitly set.
  public var hasFileContents: Bool {return _storage._fileContents != nil}
  /// Clears the value of `fileContents`. Subsequent reads from it will return its default value.
  public mutating func clearFileContents() {_uniqueStorage()._fileContents = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public struct FileContents {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// The file ID of the file whose contents are being returned
    public var fileID: Proto_FileID {
      get {return _storage._fileID ?? Proto_FileID()}
      set {_uniqueStorage()._fileID = newValue}
    }
    /// Returns true if `fileID` has been explicitly set.
    public var hasFileID: Bool {return _storage._fileID != nil}
    /// Clears the value of `fileID`. Subsequent reads from it will return its default value.
    public mutating func clearFileID() {_uniqueStorage()._fileID = nil}

    /// The bytes contained in the file
    public var contents: Data {
      get {return _storage._contents}
      set {_uniqueStorage()._contents = newValue}
    }

    public var unknownFields = SwiftProtobuf.UnknownStorage()

    public init() {}

    fileprivate var _storage = _StorageClass.defaultInstance
  }

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_FileGetContentsQuery: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileGetContentsQuery"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "header"),
    2: .same(proto: "fileID"),
  ]

  fileprivate class _StorageClass {
    var _header: Proto_QueryHeader? = nil
    var _fileID: Proto_FileID? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _header = source._header
      _fileID = source._fileID
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
        case 1: try decoder.decodeSingularMessageField(value: &_storage._header)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._fileID)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._header {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if let v = _storage._fileID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_FileGetContentsQuery, rhs: Proto_FileGetContentsQuery) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._header != rhs_storage._header {return false}
        if _storage._fileID != rhs_storage._fileID {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_FileGetContentsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileGetContentsResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "header"),
    2: .same(proto: "fileContents"),
  ]

  fileprivate class _StorageClass {
    var _header: Proto_ResponseHeader? = nil
    var _fileContents: Proto_FileGetContentsResponse.FileContents? = nil

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _header = source._header
      _fileContents = source._fileContents
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
        case 1: try decoder.decodeSingularMessageField(value: &_storage._header)
        case 2: try decoder.decodeSingularMessageField(value: &_storage._fileContents)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._header {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if let v = _storage._fileContents {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_FileGetContentsResponse, rhs: Proto_FileGetContentsResponse) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._header != rhs_storage._header {return false}
        if _storage._fileContents != rhs_storage._fileContents {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_FileGetContentsResponse.FileContents: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = Proto_FileGetContentsResponse.protoMessageName + ".FileContents"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "fileID"),
    2: .same(proto: "contents"),
  ]

  fileprivate class _StorageClass {
    var _fileID: Proto_FileID? = nil
    var _contents: Data = SwiftProtobuf.Internal.emptyData

    static let defaultInstance = _StorageClass()

    private init() {}

    init(copying source: _StorageClass) {
      _fileID = source._fileID
      _contents = source._contents
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
        case 1: try decoder.decodeSingularMessageField(value: &_storage._fileID)
        case 2: try decoder.decodeSingularBytesField(value: &_storage._contents)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._fileID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      }
      if !_storage._contents.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._contents, fieldNumber: 2)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_FileGetContentsResponse.FileContents, rhs: Proto_FileGetContentsResponse.FileContents) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._fileID != rhs_storage._fileID {return false}
        if _storage._contents != rhs_storage._contents {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
