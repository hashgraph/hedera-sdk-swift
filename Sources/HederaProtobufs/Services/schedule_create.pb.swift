// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: schedule_create.proto
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
/// Create a new <i>schedule entity</i> (or simply, <i>schedule</i>) in the network's action queue.
/// Upon <tt>SUCCESS</tt>, the receipt contains the `ScheduleID` of the created schedule. A schedule
/// entity includes a <tt>scheduledTransactionBody</tt> to be executed.
/// When the schedule has collected enough signing Ed25519 keys to satisfy the schedule's signing
/// requirements, the schedule can be executed.
///
/// If Long Term Scheduled Transactions are enabled and <tt>wait_for_expiry</tt> is set to <tt>true</tt>, then the schedule
/// will execute at it's <tt>expiration_time</tt>.
///
/// Otherwise it will execute immediately after the transaction that provided enough Ed25519 keys, a <tt>ScheduleCreate</tt>
/// or <tt>ScheduleSign</tt>.
///
/// Upon `SUCCESS`, the receipt also includes the <tt>scheduledTransactionID</tt> to
/// use to query for the record of the scheduled transaction's execution (if it occurs). 
/// 
/// The expiration time of a schedule is controlled by it's <tt>expiration_time</tt>. It remains in state and can be queried
/// using <tt>GetScheduleInfo</tt> until expiration, no matter if the scheduled transaction has
/// executed or marked deleted. If Long Term Scheduled Transactions are disabled, the <tt>expiration_time</tt> is always
/// 30 minutes in the future.
/// 
/// If the <tt>adminKey</tt> field is omitted, the resulting schedule is immutable. If the
/// <tt>adminKey</tt> is set, the <tt>ScheduleDelete</tt> transaction can be used to mark it as
/// deleted. The creator may also specify an optional <tt>memo</tt> whose UTF-8 encoding is at most
/// 100 bytes and does not include the zero byte is also supported.
/// 
/// When a <tt>scheduledTransactionBody</tt> is executed, the
/// network only charges its payer the service fee, and not the node and network fees. If the
/// optional <tt>payerAccountID</tt> is set, the network charges this account. Otherwise it charges
/// the payer of the originating <tt>ScheduleCreate</tt>.  
/// 
/// Two <tt>ScheduleCreate</tt> transactions are <i>identical</i> if they are equal in all their
/// fields other than <tt>payerAccountID</tt>.  (For the <tt>scheduledTransactionBody</tt> field,
/// "equal" should be understood in the sense of
/// gRPC object equality in the network software runtime. In particular, a gRPC object with <a
/// href="https://developers.google.com/protocol-buffers/docs/proto3#unknowns">unknown fields</a> is
/// not equal to a gRPC object without unknown fields, even if they agree on all known fields.) 
/// 
/// A <tt>ScheduleCreate</tt> transaction that attempts to re-create an identical schedule already in
/// state will receive a receipt with status <tt>IDENTICAL_SCHEDULE_ALREADY_CREATED</tt>; the receipt
/// will include the <tt>ScheduleID</tt> of the extant schedule, which may be used in a subsequent
/// <tt>ScheduleSign</tt> transaction. (The receipt will also include the <tt>TransactionID</tt> to
/// use in querying for the receipt or record of the scheduled transaction.)
/// 
/// Other notable response codes include, <tt>INVALID_ACCOUNT_ID</tt>,
/// <tt>UNSCHEDULABLE_TRANSACTION</tt>, <tt>UNRESOLVABLE_REQUIRED_SIGNERS</tt>,
/// <tt>INVALID_SIGNATURE</tt>. For more information please see the section of this documentation on
/// the <tt>ResponseCode</tt> enum. 
public struct Proto_ScheduleCreateTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The scheduled transaction
  public var scheduledTransactionBody: Proto_SchedulableTransactionBody {
    get {return _scheduledTransactionBody ?? Proto_SchedulableTransactionBody()}
    set {_scheduledTransactionBody = newValue}
  }
  /// Returns true if `scheduledTransactionBody` has been explicitly set.
  public var hasScheduledTransactionBody: Bool {return self._scheduledTransactionBody != nil}
  /// Clears the value of `scheduledTransactionBody`. Subsequent reads from it will return its default value.
  public mutating func clearScheduledTransactionBody() {self._scheduledTransactionBody = nil}

  ///*
  /// An optional memo with a UTF-8 encoding of no more than 100 bytes which does not contain the
  /// zero byte
  public var memo: String = String()

  ///*
  /// An optional Hedera key which can be used to sign a ScheduleDelete and remove the schedule
  public var adminKey: Proto_Key {
    get {return _adminKey ?? Proto_Key()}
    set {_adminKey = newValue}
  }
  /// Returns true if `adminKey` has been explicitly set.
  public var hasAdminKey: Bool {return self._adminKey != nil}
  /// Clears the value of `adminKey`. Subsequent reads from it will return its default value.
  public mutating func clearAdminKey() {self._adminKey = nil}

  ///*
  /// An optional id of the account to be charged the service fee for the scheduled transaction at
  /// the consensus time that it executes (if ever); defaults to the ScheduleCreate payer if not
  /// given
  public var payerAccountID: Proto_AccountID {
    get {return _payerAccountID ?? Proto_AccountID()}
    set {_payerAccountID = newValue}
  }
  /// Returns true if `payerAccountID` has been explicitly set.
  public var hasPayerAccountID: Bool {return self._payerAccountID != nil}
  /// Clears the value of `payerAccountID`. Subsequent reads from it will return its default value.
  public mutating func clearPayerAccountID() {self._payerAccountID = nil}

  ///*
  /// An optional timestamp for specifying when the transaction should be evaluated for execution and then expire.
  /// Defaults to 30 minutes after the transaction's consensus timestamp.
  ///
  /// Note: This field is unused and forced to be unset until Long Term Scheduled Transactions are enabled - Transactions will always
  ///       expire in 30 minutes if Long Term Scheduled Transactions are not enabled.
  public var expirationTime: Proto_Timestamp {
    get {return _expirationTime ?? Proto_Timestamp()}
    set {_expirationTime = newValue}
  }
  /// Returns true if `expirationTime` has been explicitly set.
  public var hasExpirationTime: Bool {return self._expirationTime != nil}
  /// Clears the value of `expirationTime`. Subsequent reads from it will return its default value.
  public mutating func clearExpirationTime() {self._expirationTime = nil}

  ///*
  /// When set to true, the transaction will be evaluated for execution at expiration_time instead
  /// of when all required signatures are received.
  /// When set to false, the transaction will execute immediately after sufficient signatures are received
  /// to sign the contained transaction. During the initial ScheduleCreate transaction or via ScheduleSign transactions.
  ///
  /// Defaults to false.
  ///
  /// Setting this to false does not necessarily mean that the transaction will never execute at expiration_time.
  ///  For Example - If the signature requirements for a Scheduled Transaction change via external means (e.g. CryptoUpdate)
  ///  such that the Scheduled Transaction would be allowed to execute, it will do so autonomously at expiration_time, unless a
  ///  ScheduleSign comes in to "poke" it and force it to go through immediately.
  ///
  /// Note: This field is unused and forced to be unset until Long Term Scheduled Transactions are enabled. Before Long Term
  ///       Scheduled Transactions are enabled, Scheduled Transactions will _never_ execute at expiration  - they will _only_
  ///       execute during the initial ScheduleCreate transaction or via ScheduleSign transactions and will _always_
  ///       expire at expiration_time.
  public var waitForExpiry: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _scheduledTransactionBody: Proto_SchedulableTransactionBody? = nil
  fileprivate var _adminKey: Proto_Key? = nil
  fileprivate var _payerAccountID: Proto_AccountID? = nil
  fileprivate var _expirationTime: Proto_Timestamp? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_ScheduleCreateTransactionBody: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ScheduleCreateTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ScheduleCreateTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "scheduledTransactionBody"),
    2: .same(proto: "memo"),
    3: .same(proto: "adminKey"),
    4: .same(proto: "payerAccountID"),
    5: .standard(proto: "expiration_time"),
    13: .standard(proto: "wait_for_expiry"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._scheduledTransactionBody) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.memo) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._adminKey) }()
      case 4: try { try decoder.decodeSingularMessageField(value: &self._payerAccountID) }()
      case 5: try { try decoder.decodeSingularMessageField(value: &self._expirationTime) }()
      case 13: try { try decoder.decodeSingularBoolField(value: &self.waitForExpiry) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._scheduledTransactionBody {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.memo.isEmpty {
      try visitor.visitSingularStringField(value: self.memo, fieldNumber: 2)
    }
    try { if let v = self._adminKey {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try { if let v = self._payerAccountID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    try { if let v = self._expirationTime {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    } }()
    if self.waitForExpiry != false {
      try visitor.visitSingularBoolField(value: self.waitForExpiry, fieldNumber: 13)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ScheduleCreateTransactionBody, rhs: Proto_ScheduleCreateTransactionBody) -> Bool {
    if lhs._scheduledTransactionBody != rhs._scheduledTransactionBody {return false}
    if lhs.memo != rhs.memo {return false}
    if lhs._adminKey != rhs._adminKey {return false}
    if lhs._payerAccountID != rhs._payerAccountID {return false}
    if lhs._expirationTime != rhs._expirationTime {return false}
    if lhs.waitForExpiry != rhs.waitForExpiry {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
