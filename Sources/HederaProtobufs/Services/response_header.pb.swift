// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: response_header.proto
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
/// Every query receives a response containing the QueryResponseHeader. Either or both of the cost
/// and stateProof fields may be blank, if the responseType didn't ask for the cost or stateProof.
public struct Proto_ResponseHeader: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Result of fee transaction precheck, saying it passed, or why it failed
  public var nodeTransactionPrecheckCode: Proto_ResponseCodeEnum = .ok

  ///*
  /// The requested response is repeated back here, for convenience
  public var responseType: Proto_ResponseType = .answerOnly

  ///*
  /// The fee that would be charged to get the requested information (if a cost was requested).
  /// Note: This cost only includes the query fee and does not include the transfer fee(which is
  /// required to execute the transfer transaction to debit the payer account and credit the node
  /// account with query fee)
  public var cost: UInt64 = 0

  ///*
  /// The state proof for this information (if a state proof was requested, and is available)
  public var stateProof: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ResponseHeader: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ResponseHeader"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "nodeTransactionPrecheckCode"),
    2: .same(proto: "responseType"),
    3: .same(proto: "cost"),
    4: .same(proto: "stateProof"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.nodeTransactionPrecheckCode) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.responseType) }()
      case 3: try { try decoder.decodeSingularUInt64Field(value: &self.cost) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.stateProof) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.nodeTransactionPrecheckCode != .ok {
      try visitor.visitSingularEnumField(value: self.nodeTransactionPrecheckCode, fieldNumber: 1)
    }
    if self.responseType != .answerOnly {
      try visitor.visitSingularEnumField(value: self.responseType, fieldNumber: 2)
    }
    if self.cost != 0 {
      try visitor.visitSingularUInt64Field(value: self.cost, fieldNumber: 3)
    }
    if !self.stateProof.isEmpty {
      try visitor.visitSingularBytesField(value: self.stateProof, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ResponseHeader, rhs: Proto_ResponseHeader) -> Bool {
    if lhs.nodeTransactionPrecheckCode != rhs.nodeTransactionPrecheckCode {return false}
    if lhs.responseType != rhs.responseType {return false}
    if lhs.cost != rhs.cost {return false}
    if lhs.stateProof != rhs.stateProof {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
