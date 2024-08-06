// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: exchange_rate.proto
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
/// An exchange rate between hbar and cents (USD) and the time at which the exchange rate will
/// expire, and be superseded by a new exchange rate. 
public struct Proto_ExchangeRate {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Denominator in calculation of exchange rate between hbar and cents
  public var hbarEquiv: Int32 = 0

  ///*
  /// Numerator in calculation of exchange rate between hbar and cents
  public var centEquiv: Int32 = 0

  ///*
  /// Expiration time in seconds for this exchange rate
  public var expirationTime: Proto_TimestampSeconds {
    get {return _expirationTime ?? Proto_TimestampSeconds()}
    set {_expirationTime = newValue}
  }
  /// Returns true if `expirationTime` has been explicitly set.
  public var hasExpirationTime: Bool {return self._expirationTime != nil}
  /// Clears the value of `expirationTime`. Subsequent reads from it will return its default value.
  public mutating func clearExpirationTime() {self._expirationTime = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _expirationTime: Proto_TimestampSeconds? = nil
}

///*
/// Two sets of exchange rates
public struct Proto_ExchangeRateSet {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Current exchange rate
  public var currentRate: Proto_ExchangeRate {
    get {return _currentRate ?? Proto_ExchangeRate()}
    set {_currentRate = newValue}
  }
  /// Returns true if `currentRate` has been explicitly set.
  public var hasCurrentRate: Bool {return self._currentRate != nil}
  /// Clears the value of `currentRate`. Subsequent reads from it will return its default value.
  public mutating func clearCurrentRate() {self._currentRate = nil}

  ///*
  /// Next exchange rate which will take effect when current rate expires
  public var nextRate: Proto_ExchangeRate {
    get {return _nextRate ?? Proto_ExchangeRate()}
    set {_nextRate = newValue}
  }
  /// Returns true if `nextRate` has been explicitly set.
  public var hasNextRate: Bool {return self._nextRate != nil}
  /// Clears the value of `nextRate`. Subsequent reads from it will return its default value.
  public mutating func clearNextRate() {self._nextRate = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _currentRate: Proto_ExchangeRate? = nil
  fileprivate var _nextRate: Proto_ExchangeRate? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_ExchangeRate: @unchecked Sendable {}
extension Proto_ExchangeRateSet: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ExchangeRate: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExchangeRate"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "hbarEquiv"),
    2: .same(proto: "centEquiv"),
    3: .same(proto: "expirationTime"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.hbarEquiv) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.centEquiv) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._expirationTime) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.hbarEquiv != 0 {
      try visitor.visitSingularInt32Field(value: self.hbarEquiv, fieldNumber: 1)
    }
    if self.centEquiv != 0 {
      try visitor.visitSingularInt32Field(value: self.centEquiv, fieldNumber: 2)
    }
    try { if let v = self._expirationTime {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ExchangeRate, rhs: Proto_ExchangeRate) -> Bool {
    if lhs.hbarEquiv != rhs.hbarEquiv {return false}
    if lhs.centEquiv != rhs.centEquiv {return false}
    if lhs._expirationTime != rhs._expirationTime {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_ExchangeRateSet: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExchangeRateSet"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "currentRate"),
    2: .same(proto: "nextRate"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._currentRate) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._nextRate) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._currentRate {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._nextRate {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ExchangeRateSet, rhs: Proto_ExchangeRateSet) -> Bool {
    if lhs._currentRate != rhs._currentRate {return false}
    if lhs._nextRate != rhs._nextRate {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
