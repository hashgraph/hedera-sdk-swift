// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: token_fee_schedule_update.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

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
/// At consensus, updates a token type's fee schedule to the given list of custom fees. 
/// 
/// If the target token type has no fee_schedule_key, resolves to TOKEN_HAS_NO_FEE_SCHEDULE_KEY.
/// Otherwise this transaction must be signed to the fee_schedule_key, or the transaction will 
/// resolve to INVALID_SIGNATURE.
/// 
/// If the custom_fees list is empty, clears the fee schedule or resolves to 
/// CUSTOM_SCHEDULE_ALREADY_HAS_NO_FEES if the fee schedule was already empty.
public struct Proto_TokenFeeScheduleUpdateTransactionBody: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The token whose fee schedule is to be updated
  public var tokenID: Proto_TokenID {
    get {return _tokenID ?? Proto_TokenID()}
    set {_tokenID = newValue}
  }
  /// Returns true if `tokenID` has been explicitly set.
  public var hasTokenID: Bool {return self._tokenID != nil}
  /// Clears the value of `tokenID`. Subsequent reads from it will return its default value.
  public mutating func clearTokenID() {self._tokenID = nil}

  ///*
  /// The new custom fees to be assessed during a CryptoTransfer that transfers units of this token
  public var customFees: [Proto_CustomFee] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _tokenID: Proto_TokenID? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_TokenFeeScheduleUpdateTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TokenFeeScheduleUpdateTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "token_id"),
    2: .standard(proto: "custom_fees"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._tokenID) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.customFees) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._tokenID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.customFees.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.customFees, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TokenFeeScheduleUpdateTransactionBody, rhs: Proto_TokenFeeScheduleUpdateTransactionBody) -> Bool {
    if lhs._tokenID != rhs._tokenID {return false}
    if lhs.customFees != rhs.customFees {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
