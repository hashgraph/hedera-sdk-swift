// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: state/recordcache/recordcache.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

///*
/// # Record Cache
/// The Record Cache holds transaction records for a short time, and is the
/// source for responses to `transactionGetRecord` and `transactionGetReceipt`
/// queries.
///
/// ### Keywords
/// The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
/// "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
/// document are to be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119)
/// and clarified in [RFC8174](https://www.ietf.org/rfc/rfc8174).

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
/// As transactions are handled and records and receipts are created, they are
/// stored in state for a configured time period (for example, 3 minutes).
/// During this time, any client can query the node and get the record or receipt
/// for the transaction. The `TransactionRecordEntry` is the object stored in
/// state with this information.
public struct Proto_TransactionRecordEntry: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A node identifier.<br/>
  /// This identifier is the node, as known to the address book, that
  /// submitted the transaction for consensus.
  /// <p>
  /// This SHALL be a whole number.
  public var nodeID: Int64 = 0

  ///*
  /// An Account identifier for the payer for the transaction.
  /// <p>
  /// This MAY be the same as the account ID within the Transaction ID of the
  /// record, or it MAY be the account ID of the node that submitted the
  /// transaction to consensus if the account ID in the Transaction ID was
  /// not able to pay.
  public var payerAccountID: Proto_AccountID {
    get {return _payerAccountID ?? Proto_AccountID()}
    set {_payerAccountID = newValue}
  }
  /// Returns true if `payerAccountID` has been explicitly set.
  public var hasPayerAccountID: Bool {return self._payerAccountID != nil}
  /// Clears the value of `payerAccountID`. Subsequent reads from it will return its default value.
  public mutating func clearPayerAccountID() {self._payerAccountID = nil}

  ///*
  /// A transaction record for the transaction.
  public var transactionRecord: Proto_TransactionRecord {
    get {return _transactionRecord ?? Proto_TransactionRecord()}
    set {_transactionRecord = newValue}
  }
  /// Returns true if `transactionRecord` has been explicitly set.
  public var hasTransactionRecord: Bool {return self._transactionRecord != nil}
  /// Clears the value of `transactionRecord`. Subsequent reads from it will return its default value.
  public mutating func clearTransactionRecord() {self._transactionRecord = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _payerAccountID: Proto_AccountID? = nil
  fileprivate var _transactionRecord: Proto_TransactionRecord? = nil
}

///*
/// An entry in the record cache with the receipt for a transaction.
/// This is the entry stored in state that enables returning the receipt
/// information when queried by clients.
///
/// When a transaction is handled a receipt SHALL be created.<br/>
/// This receipt MUST be stored in state for a configured time limit
/// (e.g. 3 minutes).<br/>
/// While a receipt is stored, a client MAY query the node and retrieve
/// the receipt.
public struct Proto_TransactionReceiptEntry: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A node identifier.<br/>
  /// This identifies the node that submitted the transaction to consensus.
  /// The value is the identifier as known to the current address book.
  /// <p>
  /// Valid node identifiers SHALL be between 0 and <tt>2<sup>63-1</sup></tt>,
  /// inclusive.
  public var nodeID: UInt64 = 0

  ///*
  /// A transaction identifier.<br/>
  /// This identifies the submitted transaction for this receipt.
  public var transactionID: Proto_TransactionID {
    get {return _transactionID ?? Proto_TransactionID()}
    set {_transactionID = newValue}
  }
  /// Returns true if `transactionID` has been explicitly set.
  public var hasTransactionID: Bool {return self._transactionID != nil}
  /// Clears the value of `transactionID`. Subsequent reads from it will return its default value.
  public mutating func clearTransactionID() {self._transactionID = nil}

  ///*
  /// A status result.<br/>
  /// This is the final status after handling the transaction.
  public var status: Proto_ResponseCodeEnum = .ok

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _transactionID: Proto_TransactionID? = nil
}

///*
/// A cache of transaction receipts.<br/>
/// As transactions are handled and receipts are created, they are stored in
/// state for a configured time limit (perhaps, for example, 3 minutes).
/// During this time window, any client can query the node and get the receipt
/// for the transaction. The `TransactionReceiptEntries` is the object stored in
/// state with this information.
///
/// This message SHALL contain a list of `TransactionReceiptEntry` objects.
public struct Proto_TransactionReceiptEntries: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var entries: [Proto_TransactionReceiptEntry] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_TransactionRecordEntry: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TransactionRecordEntry"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "node_id"),
    2: .standard(proto: "payer_account_id"),
    3: .standard(proto: "transaction_record"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.nodeID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._payerAccountID) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._transactionRecord) }()
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
      try visitor.visitSingularInt64Field(value: self.nodeID, fieldNumber: 1)
    }
    try { if let v = self._payerAccountID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._transactionRecord {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TransactionRecordEntry, rhs: Proto_TransactionRecordEntry) -> Bool {
    if lhs.nodeID != rhs.nodeID {return false}
    if lhs._payerAccountID != rhs._payerAccountID {return false}
    if lhs._transactionRecord != rhs._transactionRecord {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_TransactionReceiptEntry: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TransactionReceiptEntry"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "node_id"),
    2: .standard(proto: "transaction_id"),
    3: .same(proto: "status"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.nodeID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._transactionID) }()
      case 3: try { try decoder.decodeSingularEnumField(value: &self.status) }()
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
    try { if let v = self._transactionID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if self.status != .ok {
      try visitor.visitSingularEnumField(value: self.status, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TransactionReceiptEntry, rhs: Proto_TransactionReceiptEntry) -> Bool {
    if lhs.nodeID != rhs.nodeID {return false}
    if lhs._transactionID != rhs._transactionID {return false}
    if lhs.status != rhs.status {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_TransactionReceiptEntries: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".TransactionReceiptEntries"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "entries"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.entries) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.entries.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.entries, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_TransactionReceiptEntries, rhs: Proto_TransactionReceiptEntries) -> Bool {
    if lhs.entries != rhs.entries {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
