// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: consensus_submit_message.proto
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
/// UNDOCUMENTED
public struct Proto_ConsensusMessageChunkInfo: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// TransactionID of the first chunk, gets copied to every subsequent chunk in a fragmented message.
  public var initialTransactionID: Proto_TransactionID {
    get {return _initialTransactionID ?? Proto_TransactionID()}
    set {_initialTransactionID = newValue}
  }
  /// Returns true if `initialTransactionID` has been explicitly set.
  public var hasInitialTransactionID: Bool {return self._initialTransactionID != nil}
  /// Clears the value of `initialTransactionID`. Subsequent reads from it will return its default value.
  public mutating func clearInitialTransactionID() {self._initialTransactionID = nil}

  ///*
  /// The total number of chunks in the message.
  public var total: Int32 = 0

  ///*
  /// The sequence number (from 1 to total) of the current chunk in the message.
  public var number: Int32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _initialTransactionID: Proto_TransactionID? = nil
}

///*
/// UNDOCUMENTED
public struct Proto_ConsensusSubmitMessageTransactionBody: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Topic to submit message to.
  public var topicID: Proto_TopicID {
    get {return _topicID ?? Proto_TopicID()}
    set {_topicID = newValue}
  }
  /// Returns true if `topicID` has been explicitly set.
  public var hasTopicID: Bool {return self._topicID != nil}
  /// Clears the value of `topicID`. Subsequent reads from it will return its default value.
  public mutating func clearTopicID() {self._topicID = nil}

  ///*
  /// Message to be submitted. Max size of the Transaction (including signatures) is 6KiB.
  public var message: Data = Data()

  ///*
  /// Optional information of the current chunk in a fragmented message.
  public var chunkInfo: Proto_ConsensusMessageChunkInfo {
    get {return _chunkInfo ?? Proto_ConsensusMessageChunkInfo()}
    set {_chunkInfo = newValue}
  }
  /// Returns true if `chunkInfo` has been explicitly set.
  public var hasChunkInfo: Bool {return self._chunkInfo != nil}
  /// Clears the value of `chunkInfo`. Subsequent reads from it will return its default value.
  public mutating func clearChunkInfo() {self._chunkInfo = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _topicID: Proto_TopicID? = nil
  fileprivate var _chunkInfo: Proto_ConsensusMessageChunkInfo? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ConsensusMessageChunkInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ConsensusMessageChunkInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "initialTransactionID"),
    2: .same(proto: "total"),
    3: .same(proto: "number"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._initialTransactionID) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.total) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.number) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._initialTransactionID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if self.total != 0 {
      try visitor.visitSingularInt32Field(value: self.total, fieldNumber: 2)
    }
    if self.number != 0 {
      try visitor.visitSingularInt32Field(value: self.number, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ConsensusMessageChunkInfo, rhs: Proto_ConsensusMessageChunkInfo) -> Bool {
    if lhs._initialTransactionID != rhs._initialTransactionID {return false}
    if lhs.total != rhs.total {return false}
    if lhs.number != rhs.number {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_ConsensusSubmitMessageTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ConsensusSubmitMessageTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "topicID"),
    2: .same(proto: "message"),
    3: .same(proto: "chunkInfo"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._topicID) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.message) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._chunkInfo) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._topicID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.message.isEmpty {
      try visitor.visitSingularBytesField(value: self.message, fieldNumber: 2)
    }
    try { if let v = self._chunkInfo {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ConsensusSubmitMessageTransactionBody, rhs: Proto_ConsensusSubmitMessageTransactionBody) -> Bool {
    if lhs._topicID != rhs._topicID {return false}
    if lhs.message != rhs.message {return false}
    if lhs._chunkInfo != rhs._chunkInfo {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
