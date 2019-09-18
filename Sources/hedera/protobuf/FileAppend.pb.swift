// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: FileAppend.proto
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

/// Append the given contents to the end of the file. If a file is too big to create with a single FileCreateTransaction, then it can be created with the first part of its contents, and then appended multiple times to create the entire file. 
public struct Proto_FileAppendTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The file ID of the file to which the bytes are appended to
  public var fileID: Proto_FileID {
    get {return _storage._fileID ?? Proto_FileID()}
    set {_uniqueStorage()._fileID = newValue}
  }
  /// Returns true if `fileID` has been explicitly set.
  public var hasFileID: Bool {return _storage._fileID != nil}
  /// Clears the value of `fileID`. Subsequent reads from it will return its default value.
  public mutating func clearFileID() {_uniqueStorage()._fileID = nil}

  /// The bytes to append to the contents of the file
  public var contents: Data {
    get {return _storage._contents}
    set {_uniqueStorage()._contents = newValue}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_FileAppendTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".FileAppendTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    2: .same(proto: "fileID"),
    4: .same(proto: "contents"),
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
        case 2: try decoder.decodeSingularMessageField(value: &_storage._fileID)
        case 4: try decoder.decodeSingularBytesField(value: &_storage._contents)
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      if let v = _storage._fileID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      }
      if !_storage._contents.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._contents, fieldNumber: 4)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_FileAppendTransactionBody, rhs: Proto_FileAppendTransactionBody) -> Bool {
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
