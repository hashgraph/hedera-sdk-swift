// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: auxiliary/tss/tss_share_signature.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

///*
/// # Tss Share Signature
/// Represents a transaction that submits a node's share signature on a block hash
/// during the TSS (Threshold Signature Scheme) process.
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

///*
/// A TSS Share Signature transaction Body.<br/>
/// This transaction body communicates a node's signature of a block hash
/// using its private share within the TSS process.
/// This transaction MUST be prioritized for low latency gossip transmission.
///
/// ### Block Stream Effects
/// This transaction body will be present in the block stream. This will not have
/// any state changes or transaction output or transaction result.
public struct Com_Hedera_Hapi_Services_Auxiliary_Tss_TssShareSignatureTransactionBody: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A SHA2-384 Hash.<br/>
  /// This is the hash of the roster that includes the node whose
  /// share produced this share signature.
  /// <p>
  /// This value is REQUIRED.<br/>
  /// This value MUST identify the network roster active at the time this
  /// share signature was produced.<br/>
  /// This share signature MUST be produced from a share distributed during
  /// the re-keying process for the identified roster.
  public var rosterHash: Data = Data()

  ///*
  /// An index of the share from the node private shares.<br/>
  /// This is the index of the share that produced this share signature.
  /// <p>
  /// This value is REQUIRED.<br/>
  /// The share referred to by this index MUST exist.<br/>
  /// The share index MUST be greater than or equal to 0.
  public var shareIndex: UInt64 = 0

  ///*
  /// A SHA2-384 hash.<br/>
  /// This is the hash of the message that was signed.
  /// <p>
  /// This value is REQUIRED.<br/>
  /// The message signed MUST be a block hash.
  public var messageHash: Data = Data()

  ///*
  /// The signature bytes.<br/>
  /// This is the signature generated by signing the block hash with the node's private share.
  /// <p>
  /// This value is REQUIRED.<br/>
  /// This value MUST be a valid signature of the message hash with the node's private share.
  public var shareSignature: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "com.hedera.hapi.services.auxiliary.tss"

extension Com_Hedera_Hapi_Services_Auxiliary_Tss_TssShareSignatureTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TssShareSignatureTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "roster_hash"),
    2: .standard(proto: "share_index"),
    3: .standard(proto: "message_hash"),
    4: .standard(proto: "share_signature"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.rosterHash) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.shareIndex) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.messageHash) }()
      case 4: try { try decoder.decodeSingularBytesField(value: &self.shareSignature) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.rosterHash.isEmpty {
      try visitor.visitSingularBytesField(value: self.rosterHash, fieldNumber: 1)
    }
    if self.shareIndex != 0 {
      try visitor.visitSingularUInt64Field(value: self.shareIndex, fieldNumber: 2)
    }
    if !self.messageHash.isEmpty {
      try visitor.visitSingularBytesField(value: self.messageHash, fieldNumber: 3)
    }
    if !self.shareSignature.isEmpty {
      try visitor.visitSingularBytesField(value: self.shareSignature, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Com_Hedera_Hapi_Services_Auxiliary_Tss_TssShareSignatureTransactionBody, rhs: Com_Hedera_Hapi_Services_Auxiliary_Tss_TssShareSignatureTransactionBody) -> Bool {
    if lhs.rosterHash != rhs.rosterHash {return false}
    if lhs.shareIndex != rhs.shareIndex {return false}
    if lhs.messageHash != rhs.messageHash {return false}
    if lhs.shareSignature != rhs.shareSignature {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
