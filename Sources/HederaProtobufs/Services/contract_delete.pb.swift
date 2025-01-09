// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: contract_delete.proto
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
/// At consensus, marks a contract as deleted and transfers its remaining hBars, if any, to a
/// designated receiver. After a contract is deleted, it can no longer be called.
/// 
/// If the target contract is immutable (that is, was created without an admin key), then this
/// transaction resolves to MODIFYING_IMMUTABLE_CONTRACT.
/// 
/// --- Signing Requirements ---
/// 1. The admin key of the target contract must sign.
/// 2. If the transfer account or contract has receiverSigRequired, its associated key must also sign
public struct Proto_ContractDeleteTransactionBody: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The id of the contract to be deleted
  public var contractID: Proto_ContractID {
    get {return _contractID ?? Proto_ContractID()}
    set {_contractID = newValue}
  }
  /// Returns true if `contractID` has been explicitly set.
  public var hasContractID: Bool {return self._contractID != nil}
  /// Clears the value of `contractID`. Subsequent reads from it will return its default value.
  public mutating func clearContractID() {self._contractID = nil}

  public var obtainers: Proto_ContractDeleteTransactionBody.OneOf_Obtainers? = nil

  ///*
  /// The id of an account to receive any remaining hBars from the deleted contract
  public var transferAccountID: Proto_AccountID {
    get {
      if case .transferAccountID(let v)? = obtainers {return v}
      return Proto_AccountID()
    }
    set {obtainers = .transferAccountID(newValue)}
  }

  ///*
  /// The id of a contract to receive any remaining hBars from the deleted contract
  public var transferContractID: Proto_ContractID {
    get {
      if case .transferContractID(let v)? = obtainers {return v}
      return Proto_ContractID()
    }
    set {obtainers = .transferContractID(newValue)}
  }

  ///*
  /// If set to true, means this is a "synthetic" system transaction being used to 
  /// alert mirror nodes that the contract is being permanently removed from the ledger.
  /// <b>IMPORTANT:</b> User transactions cannot set this field to true, as permanent
  /// removal is always managed by the ledger itself. Any ContractDeleteTransactionBody
  /// submitted to HAPI with permanent_removal=true will be rejected with precheck status
  /// PERMANENT_REMOVAL_REQUIRES_SYSTEM_INITIATION.
  public var permanentRemoval: Bool = false

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public enum OneOf_Obtainers: Equatable, Sendable {
    ///*
    /// The id of an account to receive any remaining hBars from the deleted contract
    case transferAccountID(Proto_AccountID)
    ///*
    /// The id of a contract to receive any remaining hBars from the deleted contract
    case transferContractID(Proto_ContractID)

  }

  public init() {}

  fileprivate var _contractID: Proto_ContractID? = nil
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ContractDeleteTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ContractDeleteTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "contractID"),
    2: .same(proto: "transferAccountID"),
    3: .same(proto: "transferContractID"),
    4: .standard(proto: "permanent_removal"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._contractID) }()
      case 2: try {
        var v: Proto_AccountID?
        var hadOneofValue = false
        if let current = self.obtainers {
          hadOneofValue = true
          if case .transferAccountID(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.obtainers = .transferAccountID(v)
        }
      }()
      case 3: try {
        var v: Proto_ContractID?
        var hadOneofValue = false
        if let current = self.obtainers {
          hadOneofValue = true
          if case .transferContractID(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.obtainers = .transferContractID(v)
        }
      }()
      case 4: try { try decoder.decodeSingularBoolField(value: &self.permanentRemoval) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._contractID {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    switch self.obtainers {
    case .transferAccountID?: try {
      guard case .transferAccountID(let v)? = self.obtainers else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .transferContractID?: try {
      guard case .transferContractID(let v)? = self.obtainers else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case nil: break
    }
    if self.permanentRemoval != false {
      try visitor.visitSingularBoolField(value: self.permanentRemoval, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ContractDeleteTransactionBody, rhs: Proto_ContractDeleteTransactionBody) -> Bool {
    if lhs._contractID != rhs._contractID {return false}
    if lhs.obtainers != rhs.obtainers {return false}
    if lhs.permanentRemoval != rhs.permanentRemoval {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
