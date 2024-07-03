// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: state/addressbook/node.proto
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

public enum Proto_NodeStatus: SwiftProtobuf.Enum {
  public typealias RawValue = Int

  ///*
  /// node in this state is deleted
  case deleted // = 0

  ///*
  /// node in this state is waiting to be added by consensus roster
  case pendingAddition // = 1

  ///*
  ///  node in this state is waiting to be deleted by consensus roster
  case pendingDeletion // = 2

  ///*
  /// node in this state is active on the network and participating
  /// in network consensus.
  case inConsensus // = 3
  case UNRECOGNIZED(Int)

  public init() {
    self = .deleted
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .deleted
    case 1: self = .pendingAddition
    case 2: self = .pendingDeletion
    case 3: self = .inConsensus
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .deleted: return 0
    case .pendingAddition: return 1
    case .pendingDeletion: return 2
    case .inConsensus: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

}

#if swift(>=4.2)

extension Proto_NodeStatus: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static let allCases: [Proto_NodeStatus] = [
    .deleted,
    .pendingAddition,
    .pendingDeletion,
    .inConsensus,
  ]
}

#endif  // swift(>=4.2)

///*
/// Representation of a Node in the network Merkle tree
///
/// A Node is identified by a single uint64 number, which is unique among all nodes.
public struct Proto_Node {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The unique id of the Node.
  public var nodeID: UInt64 = 0

  ///*
  /// The account is charged for transactions submitted by the node that fail due diligence
  public var accountID: Proto_AccountID {
    get {return _accountID ?? Proto_AccountID()}
    set {_accountID = newValue}
  }
  /// Returns true if `accountID` has been explicitly set.
  public var hasAccountID: Bool {return self._accountID != nil}
  /// Clears the value of `accountID`. Subsequent reads from it will return its default value.
  public mutating func clearAccountID() {self._accountID = nil}

  ///*
  /// A description of the node, with UTF-8 encoding up to 100 bytes
  public var description_p: String = String()

  ///*
  /// Node Gossip Endpoints, ip address or FQDN and port
  public var gossipEndpoint: [Proto_ServiceEndpoint] = []

  ///*
  /// A node's service Endpoints, ip address or FQDN and port
  public var serviceEndpoint: [Proto_ServiceEndpoint] = []

  ///*
  /// The node's X509 certificate used to sign stream files (e.g., record stream
  /// files). Precisely, this field is the DER encoding of gossip X509 certificate.
  public var gossipCaCertificate: Data = Data()

  ///*
  /// node x509 certificate hash. Hash of the node's TLS certificate. Precisely, this field is a string of
  /// hexadecimal characters which, translated to binary, are the SHA-384 hash of
  /// the UTF-8 NFKD encoding of the node's TLS cert in PEM format. Its value can be
  /// used to verify the node's certificate it presents during TLS negotiations.
  public var grpcCertificateHash: Data = Data()

  ///*
  /// The consensus weight of this node in the network.
  public var weight: UInt64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _accountID: Proto_AccountID? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_NodeStatus: @unchecked Sendable {}
extension Proto_Node: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_NodeStatus: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "DELETED"),
    1: .same(proto: "PENDING_ADDITION"),
    2: .same(proto: "PENDING_DELETION"),
    3: .same(proto: "IN_CONSENSUS"),
  ]
}

extension Proto_Node: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Node"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "node_id"),
    2: .standard(proto: "account_id"),
    3: .same(proto: "description"),
    4: .standard(proto: "gossip_endpoint"),
    5: .standard(proto: "service_endpoint"),
    6: .standard(proto: "gossip_ca_certificate"),
    7: .standard(proto: "grpc_certificate_hash"),
    8: .same(proto: "weight"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.nodeID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._accountID) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.description_p) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.gossipEndpoint) }()
      case 5: try { try decoder.decodeRepeatedMessageField(value: &self.serviceEndpoint) }()
      case 6: try { try decoder.decodeSingularBytesField(value: &self.gossipCaCertificate) }()
      case 7: try { try decoder.decodeSingularBytesField(value: &self.grpcCertificateHash) }()
      case 8: try { try decoder.decodeSingularUInt64Field(value: &self.weight) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.nodeID != 0 {
      try visitor.visitSingularUInt64Field(value: self.nodeID, fieldNumber: 1)
    }
    try { if let v = self._accountID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.description_p.isEmpty {
      try visitor.visitSingularStringField(value: self.description_p, fieldNumber: 3)
    }
    if !self.gossipEndpoint.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.gossipEndpoint, fieldNumber: 4)
    }
    if !self.serviceEndpoint.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.serviceEndpoint, fieldNumber: 5)
    }
    if !self.gossipCaCertificate.isEmpty {
      try visitor.visitSingularBytesField(value: self.gossipCaCertificate, fieldNumber: 6)
    }
    if !self.grpcCertificateHash.isEmpty {
      try visitor.visitSingularBytesField(value: self.grpcCertificateHash, fieldNumber: 7)
    }
    if self.weight != 0 {
      try visitor.visitSingularUInt64Field(value: self.weight, fieldNumber: 8)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_Node, rhs: Proto_Node) -> Bool {
    if lhs.nodeID != rhs.nodeID {return false}
    if lhs._accountID != rhs._accountID {return false}
    if lhs.description_p != rhs.description_p {return false}
    if lhs.gossipEndpoint != rhs.gossipEndpoint {return false}
    if lhs.serviceEndpoint != rhs.serviceEndpoint {return false}
    if lhs.gossipCaCertificate != rhs.gossipCaCertificate {return false}
    if lhs.grpcCertificateHash != rhs.grpcCertificateHash {return false}
    if lhs.weight != rhs.weight {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}