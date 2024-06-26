// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: node_get_info.proto
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
/// Gets information about Node instance. This needs super use privileges to succeed or should be a node operator.
public struct Proto_NodeGetInfoQuery {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Standard information sent with every query operation.<br/>
  /// This includes the signed payment and what kind of response is requested
  /// (cost, state proof, both, or neither).
  public var header: Proto_QueryHeader {
    get {return _header ?? Proto_QueryHeader()}
    set {_header = newValue}
  }
  /// Returns true if `header` has been explicitly set.
  public var hasHeader: Bool {return self._header != nil}
  /// Clears the value of `header`. Subsequent reads from it will return its default value.
  public mutating func clearHeader() {self._header = nil}

  ///*
  /// A node identifier for which information is requested.<br/>
  /// If the identified node is not valid, this request SHALL fail with
  /// a response code `INVALID_NODE_ID`.
  public var nodeID: UInt64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _header: Proto_QueryHeader? = nil
}

///*
/// A query response describing the current state of a node
public struct Proto_NodeInfo {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A numeric node identifier.<br/>
  /// This value identifies this node within the network address book.
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
  /// A description of the node with UTF-8 encoding up to 100 bytes
  public var description_p: String = String()

  ///*
  /// A node's Gossip Endpoints, ip address and port
  public var gossipEndpoint: [Proto_ServiceEndpoint] = []

  ///*
  /// A node's service Endpoints, ip address or FQDN and port
  public var serviceEndpoint: [Proto_ServiceEndpoint] = []

  ///*
  /// The node's X509 certificate used to sign stream files (e.g., record stream
  /// files). Precisely, this field is the DER encoding of gossip X509 certificate.
  /// files).
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

  ///*
  /// Whether the node has been deleted
  public var deleted: Bool = false

  ///*
  /// A ledger ID.<br/>
  /// This identifies the network that responded to this query.
  /// The specific values are documented in [HIP-198]
  /// (https://hips.hedera.com/hip/hip-198).
  public var ledgerID: Data = Data()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _accountID: Proto_AccountID? = nil
}

///*
/// Response when the client sends the node NodeGetInfoQuery
public struct Proto_NodeGetInfoResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The standard response information for queries.<br/>
  /// This includes the values requested in the `QueryHeader`;
  /// cost, state proof, both, or neither.
  public var header: Proto_ResponseHeader {
    get {return _header ?? Proto_ResponseHeader()}
    set {_header = newValue}
  }
  /// Returns true if `header` has been explicitly set.
  public var hasHeader: Bool {return self._header != nil}
  /// Clears the value of `header`. Subsequent reads from it will return its default value.
  public mutating func clearHeader() {self._header = nil}

  ///*
  /// The information requested about this node instance
  public var nodeInfo: Proto_NodeInfo {
    get {return _nodeInfo ?? Proto_NodeInfo()}
    set {_nodeInfo = newValue}
  }
  /// Returns true if `nodeInfo` has been explicitly set.
  public var hasNodeInfo: Bool {return self._nodeInfo != nil}
  /// Clears the value of `nodeInfo`. Subsequent reads from it will return its default value.
  public mutating func clearNodeInfo() {self._nodeInfo = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _header: Proto_ResponseHeader? = nil
  fileprivate var _nodeInfo: Proto_NodeInfo? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_NodeGetInfoQuery: @unchecked Sendable {}
extension Proto_NodeInfo: @unchecked Sendable {}
extension Proto_NodeGetInfoResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_NodeGetInfoQuery: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NodeGetInfoQuery"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "header"),
    2: .standard(proto: "node_id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._header) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.nodeID) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._header {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if self.nodeID != 0 {
      try visitor.visitSingularUInt64Field(value: self.nodeID, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_NodeGetInfoQuery, rhs: Proto_NodeGetInfoQuery) -> Bool {
    if lhs._header != rhs._header {return false}
    if lhs.nodeID != rhs.nodeID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_NodeInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NodeInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "node_id"),
    2: .standard(proto: "account_id"),
    3: .same(proto: "description"),
    4: .standard(proto: "gossip_endpoint"),
    5: .standard(proto: "service_endpoint"),
    6: .standard(proto: "gossip_ca_certificate"),
    7: .standard(proto: "grpc_certificate_hash"),
    8: .same(proto: "weight"),
    10: .same(proto: "deleted"),
    9: .standard(proto: "ledger_id"),
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
      case 9: try { try decoder.decodeSingularBytesField(value: &self.ledgerID) }()
      case 10: try { try decoder.decodeSingularBoolField(value: &self.deleted) }()
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
    if !self.ledgerID.isEmpty {
      try visitor.visitSingularBytesField(value: self.ledgerID, fieldNumber: 9)
    }
    if self.deleted != false {
      try visitor.visitSingularBoolField(value: self.deleted, fieldNumber: 10)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_NodeInfo, rhs: Proto_NodeInfo) -> Bool {
    if lhs.nodeID != rhs.nodeID {return false}
    if lhs._accountID != rhs._accountID {return false}
    if lhs.description_p != rhs.description_p {return false}
    if lhs.gossipEndpoint != rhs.gossipEndpoint {return false}
    if lhs.serviceEndpoint != rhs.serviceEndpoint {return false}
    if lhs.gossipCaCertificate != rhs.gossipCaCertificate {return false}
    if lhs.grpcCertificateHash != rhs.grpcCertificateHash {return false}
    if lhs.weight != rhs.weight {return false}
    if lhs.deleted != rhs.deleted {return false}
    if lhs.ledgerID != rhs.ledgerID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_NodeGetInfoResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NodeGetInfoResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "header"),
    2: .same(proto: "nodeInfo"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._header) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._nodeInfo) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._header {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._nodeInfo {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_NodeGetInfoResponse, rhs: Proto_NodeGetInfoResponse) -> Bool {
    if lhs._header != rhs._header {return false}
    if lhs._nodeInfo != rhs._nodeInfo {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
