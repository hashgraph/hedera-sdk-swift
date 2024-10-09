// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: query_header.proto
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
/// The client uses the ResponseType to indicate that it desires the node send just the answer, or
/// both the answer and a state proof. It can also ask for just the cost and not the answer itself
/// (allowing it to tailor the payment transaction accordingly). If the payment in the query fails
/// the precheck, then the response may have some fields blank. The state proof is only available for
/// some types of information. It is available for a Record, but not a receipt. It is available for
/// the information in each kind of *GetInfo request. 
public enum Proto_ResponseType: SwiftProtobuf.Enum, Swift.CaseIterable {
  public typealias RawValue = Int

  ///*
  /// Response returns answer
  case answerOnly // = 0

  ///*
  /// (NOT YET SUPPORTED) Response returns both answer and state proof
  case answerStateProof // = 1

  ///*
  /// Response returns the cost of answer
  case costAnswer // = 2

  ///*
  /// (NOT YET SUPPORTED) Response returns the total cost of answer and state proof
  case costAnswerStateProof // = 3
  case UNRECOGNIZED(Int)

  public init() {
    self = .answerOnly
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .answerOnly
    case 1: self = .answerStateProof
    case 2: self = .costAnswer
    case 3: self = .costAnswerStateProof
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .answerOnly: return 0
    case .answerStateProof: return 1
    case .costAnswer: return 2
    case .costAnswerStateProof: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static let allCases: [Proto_ResponseType] = [
    .answerOnly,
    .answerStateProof,
    .costAnswer,
    .costAnswerStateProof,
  ]

}

///*
/// Each query from the client to the node will contain the QueryHeader, which gives the requested
/// response type, and includes a payment transaction that will compensate the node for responding to
/// the query. The payment can be blank if the query is free. 
public struct Proto_QueryHeader: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A signed CryptoTransferTransaction to pay the node a fee for handling this query
  public var payment: Proto_Transaction {
    get {return _payment ?? Proto_Transaction()}
    set {_payment = newValue}
  }
  /// Returns true if `payment` has been explicitly set.
  public var hasPayment: Bool {return self._payment != nil}
  /// Clears the value of `payment`. Subsequent reads from it will return its default value.
  public mutating func clearPayment() {self._payment = nil}

  ///*
  /// The requested response, asking for cost, state proof, both, or neither
  public var responseType: Proto_ResponseType = .answerOnly

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _payment: Proto_Transaction? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ResponseType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "ANSWER_ONLY"),
    1: .same(proto: "ANSWER_STATE_PROOF"),
    2: .same(proto: "COST_ANSWER"),
    3: .same(proto: "COST_ANSWER_STATE_PROOF"),
  ]
}

extension Proto_QueryHeader: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".QueryHeader"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "payment"),
    2: .same(proto: "responseType"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._payment) }()
      case 2: try { try decoder.decodeSingularEnumField(value: &self.responseType) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._payment {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if self.responseType != .answerOnly {
      try visitor.visitSingularEnumField(value: self.responseType, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_QueryHeader, rhs: Proto_QueryHeader) -> Bool {
    if lhs._payment != rhs._payment {return false}
    if lhs.responseType != rhs.responseType {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
