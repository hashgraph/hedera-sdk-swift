// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: crypto_transfer.proto
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
/// Transfers cryptocurrency among two or more accounts by making the desired adjustments to their
/// balances. Each transfer list can specify up to 10 adjustments. Each negative amount is withdrawn
/// from the corresponding account (a sender), and each positive one is added to the corresponding
/// account (a receiver). The amounts list must sum to zero. Each amount is a number of tinybars
/// (there are 100,000,000 tinybars in one hbar).  If any sender account fails to have sufficient
/// hbars, then the entire transaction fails, and none of those transfers occur, though the
/// transaction fee is still charged. This transaction must be signed by the keys for all the sending
/// accounts, and for any receiving accounts that have receiverSigRequired == true. The signatures
/// are in the same order as the accounts, skipping those accounts that don't need a signature. 
public struct Proto_CryptoTransferTransactionBody: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The desired hbar balance adjustments
  public var transfers: Proto_TransferList {
    get {return _transfers ?? Proto_TransferList()}
    set {_transfers = newValue}
  }
  /// Returns true if `transfers` has been explicitly set.
  public var hasTransfers: Bool {return self._transfers != nil}
  /// Clears the value of `transfers`. Subsequent reads from it will return its default value.
  public mutating func clearTransfers() {self._transfers = nil}

  ///*
  /// The desired token unit balance adjustments; if any custom fees are assessed, the ledger will
  /// try to deduct them from the payer of this CryptoTransfer, resolving the transaction to
  /// INSUFFICIENT_PAYER_BALANCE_FOR_CUSTOM_FEE if this is not possible
  public var tokenTransfers: [Proto_TokenTransferList] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _transfers: Proto_TransferList? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_CryptoTransferTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CryptoTransferTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "transfers"),
    2: .same(proto: "tokenTransfers"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._transfers) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.tokenTransfers) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._transfers {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.tokenTransfers.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.tokenTransfers, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_CryptoTransferTransactionBody, rhs: Proto_CryptoTransferTransactionBody) -> Bool {
    if lhs._transfers != rhs._transfers {return false}
    if lhs.tokenTransfers != rhs.tokenTransfers {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
