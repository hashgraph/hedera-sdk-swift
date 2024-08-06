// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: schedule_delete.proto
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
/// Marks a schedule in the network's action queue as deleted. Must be signed by the admin key of the
/// target schedule.  A deleted schedule cannot receive any additional signing keys, nor will it be
/// executed.
///
/// Other notable response codes include, <tt>INVALID_SCHEDULE_ID</tt>, <tt>SCHEDULE_PENDING_EXPIRATION</tt>,
/// <tt>SCHEDULE_ALREADY_DELETED</tt>, <tt>SCHEDULE_ALREADY_EXECUTED</tt>, <tt>SCHEDULE_IS_IMMUTABLE</tt>.
/// For more information please see the section of this documentation on the <tt>ResponseCode</tt>
/// enum. 
public struct Proto_ScheduleDeleteTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The ID of the Scheduled Entity
  public var scheduleID: Proto_ScheduleID {
    get {return _scheduleID ?? Proto_ScheduleID()}
    set {_scheduleID = newValue}
  }
  /// Returns true if `scheduleID` has been explicitly set.
  public var hasScheduleID: Bool {return self._scheduleID != nil}
  /// Clears the value of `scheduleID`. Subsequent reads from it will return its default value.
  public mutating func clearScheduleID() {self._scheduleID = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _scheduleID: Proto_ScheduleID? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_ScheduleDeleteTransactionBody: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ScheduleDeleteTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ScheduleDeleteTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "scheduleID"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._scheduleID) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._scheduleID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ScheduleDeleteTransactionBody, rhs: Proto_ScheduleDeleteTransactionBody) -> Bool {
    if lhs._scheduleID != rhs._scheduleID {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
