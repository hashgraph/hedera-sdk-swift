// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: auxiliary/tss/tss_message.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

///*
/// # Tss Message Transaction
///
/// ### Keywords
/// The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
/// "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
/// document are to be interpreted as described in
/// [RFC2119](https://www.ietf.org/rfc/rfc2119) and clarified in
/// [RFC8174](https://www.ietf.org/rfc/rfc8174).

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

///* A transaction body to to send a Threshold Signature Scheme (TSS)
/// Message.<br/>
/// This is a wrapper around several different TSS message types that a node
/// might communicate with other nodes in the network.
///
/// - A `TssMessageTransactionBody` MUST identify the hash of the roster
///   containing the node generating this TssMessage
/// - A `TssMessageTransactionBody` MUST identify the hash of the roster that
///   the TSS messages is for
/// - A `TssMessageTransactionBody` SHALL contain the specificc TssMessage data
///   that has been generated by the node for the share_index.
public struct Com_Hedera_Hapi_Services_Auxiliary_Tss_TssMessageTransactionBody: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A hash of the roster containing the node generating the TssMessage.<br/>
  /// This hash uniquely identifies the source roster, which will include
  /// an entry for the node generating this TssMessage.
  /// <p>
  /// This value MUST be set.<br/>
  /// This value MUST NOT be empty.<br/>
  /// This value MUST contain a valid hash.
  public var sourceRosterHash: Data = Data()

  ///*
  /// A hash of the roster that the TssMessage is for.
  /// <p>
  /// This value MUST be set.<br/>
  /// This value MUST NOT be empty.<br/>
  /// This value MUST contain a valid hash.
  public var targetRosterHash: Data = Data()

  ///*
  /// An index to order shares.
  /// <p>
  /// A share index SHALL establish a global ordering of shares across all
  /// shares in the network.<br/>
  /// A share index MUST correspond to the index of the public share in the list
  /// returned from the TSS library when the share was created for the source
  /// roster.
  public var shareIndex: UInt64 = 0

  ///*
  /// A byte array.
  /// <p>
  /// This field SHALL contain the TssMessage data generated by the node
  /// for the specified `share_index`.
  public var tssMessage: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "com.hedera.hapi.services.auxiliary.tss"

extension Com_Hedera_Hapi_Services_Auxiliary_Tss_TssMessageTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TssMessageTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "source_roster_hash"),
    2: .standard(proto: "target_roster_hash"),
    3: .standard(proto: "share_index"),
    4: .standard(proto: "tss_message"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.sourceRosterHash) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.targetRosterHash) }()
      case 3: try { try decoder.decodeSingularUInt64Field(value: &self.shareIndex) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.tssMessage) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.sourceRosterHash.isEmpty {
      try visitor.visitSingularBytesField(value: self.sourceRosterHash, fieldNumber: 1)
    }
    if !self.targetRosterHash.isEmpty {
      try visitor.visitSingularBytesField(value: self.targetRosterHash, fieldNumber: 2)
    }
    if self.shareIndex != 0 {
      try visitor.visitSingularUInt64Field(value: self.shareIndex, fieldNumber: 3)
    }
    if !self.tssMessage.isEmpty {
      try visitor.visitSingularBytesField(value: self.tssMessage, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Com_Hedera_Hapi_Services_Auxiliary_Tss_TssMessageTransactionBody, rhs: Com_Hedera_Hapi_Services_Auxiliary_Tss_TssMessageTransactionBody) -> Bool {
    if lhs.sourceRosterHash != rhs.sourceRosterHash {return false}
    if lhs.targetRosterHash != rhs.targetRosterHash {return false}
    if lhs.shareIndex != rhs.shareIndex {return false}
    if lhs.tssMessage != rhs.tssMessage {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
