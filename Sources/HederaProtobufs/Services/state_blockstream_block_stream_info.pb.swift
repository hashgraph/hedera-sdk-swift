// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: state/blockstream/block_stream_info.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

///*
/// # Block Stream Info
/// Information stored in consensus state at the beginning of each block to
/// record the status of the immediately prior block.
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
/// A message stored in state to maintain block stream parameters.<br/>
/// Nodes use this information for three purposes.
/// 1. To maintain hash chain continuity at restart and reconnect boundaries.
/// 1. To store historical hashes for implementation of the EVM `BLOCKHASH`
///    and `PREVRANDAO` opcodes.
/// 1. To track the amount of consensus time that has passed between blocks.
///
/// This value MUST be updated for every block.<br/>
/// This value MUST be transmitted in the "state changes" section of
/// _each_ block, but MUST be updated at the beginning of the _next_ block.<br/>
/// This value SHALL contain the block hash up to, and including, the
/// immediately prior completed block.<br/>
/// The state change to update this singleton MUST be the last
/// block item in this block.
public struct Com_Hedera_Hapi_Node_State_Blockstream_BlockStreamInfo: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// A block number.<br/>
  /// This is the current block number.
  public var blockNumber: UInt64 {
    get {return _storage._blockNumber}
    set {_uniqueStorage()._blockNumber = newValue}
  }

  ///*
  /// A consensus time for the current block.<br/>
  /// This is the consensus time of the first round in the current block,
  /// and is used to determine if this block was the first across an
  /// important boundary in consensus time, such as UTC midnight.
  /// This may also be used to purge entities expiring between the last
  /// block time and this time.
  public var blockTime: Proto_Timestamp {
    get {return _storage._blockTime ?? Proto_Timestamp()}
    set {_uniqueStorage()._blockTime = newValue}
  }
  /// Returns true if `blockTime` has been explicitly set.
  public var hasBlockTime: Bool {return _storage._blockTime != nil}
  /// Clears the value of `blockTime`. Subsequent reads from it will return its default value.
  public mutating func clearBlockTime() {_uniqueStorage()._blockTime = nil}

  ///*
  /// A concatenation of hash values.<br/>
  /// This combines several trailing output block item hashes and
  /// is used as a seed value for a pseudo-random number generator.<br/>
  /// This is also required to implement the EVM `PREVRANDAO` opcode.<br/>
  /// This MUST contain at least 256 bits of entropy.
  public var trailingOutputHashes: Data {
    get {return _storage._trailingOutputHashes}
    set {_uniqueStorage()._trailingOutputHashes = newValue}
  }

  ///*
  /// A concatenation of hash values.<br/>
  /// This field combines up to 256 trailing block hashes.
  /// <p>
  /// If this message is for block number N, then the earliest available
  /// hash SHALL be for block number N-256.<br/>
  /// The latest available hash SHALL be for block N-1.<br/>
  /// This is REQUIRED to implement the EVM `BLOCKHASH` opcode.
  /// <p>
  /// ### Field Length
  /// Each hash value SHALL be the trailing 265 bits of a SHA2-384 hash.<br/>
  /// The length of this field SHALL be an integer multiple of 32 bytes.<br/>
  /// This field SHALL be at least 32 bytes.<br/>
  /// The maximum length of this field SHALL be 8192 bytes.
  public var trailingBlockHashes: Data {
    get {return _storage._trailingBlockHashes}
    set {_uniqueStorage()._trailingBlockHashes = newValue}
  }

  ///*
  /// A SHA2-384 hash value.<br/>
  /// This is the hash of the "input" subtree for this block.
  public var inputTreeRootHash: Data {
    get {return _storage._inputTreeRootHash}
    set {_uniqueStorage()._inputTreeRootHash = newValue}
  }

  ///*
  /// A SHA2-384 hash value.<br/>
  /// This is the hash of consensus state at the _start_ of this block.
  public var startOfBlockStateHash: Data {
    get {return _storage._startOfBlockStateHash}
    set {_uniqueStorage()._startOfBlockStateHash = newValue}
  }

  ///*
  /// A count of "output" block items in this block.
  /// <p>
  /// This SHALL count the number of output block items that _precede_
  /// the state change that updates this singleton.
  public var numPrecedingOutputItems: UInt32 {
    get {return _storage._numPrecedingOutputItems}
    set {_uniqueStorage()._numPrecedingOutputItems = newValue}
  }

  ///*
  /// A concatenation of SHA2-384 hash values.<br/>
  /// This is the "rightmost" values of the "output" subtree.
  /// <p>
  /// The subtree containing these hashes SHALL be constructed from all "output"
  /// `BlockItem`s in this block that _precede_ the update to this singleton.
  public var rightmostPrecedingOutputTreeHashes: [Data] {
    get {return _storage._rightmostPrecedingOutputTreeHashes}
    set {_uniqueStorage()._rightmostPrecedingOutputTreeHashes = newValue}
  }

  ///*
  /// A block-end consensus time stamp.
  /// <p>
  /// This field SHALL hold the last-used consensus time for
  /// the current block.
  public var blockEndTime: Proto_Timestamp {
    get {return _storage._blockEndTime ?? Proto_Timestamp()}
    set {_uniqueStorage()._blockEndTime = newValue}
  }
  /// Returns true if `blockEndTime` has been explicitly set.
  public var hasBlockEndTime: Bool {return _storage._blockEndTime != nil}
  /// Clears the value of `blockEndTime`. Subsequent reads from it will return its default value.
  public mutating func clearBlockEndTime() {_uniqueStorage()._blockEndTime = nil}

  ///*
  /// Whether the post-upgrade work has been done.
  /// <p>
  /// This MUST be false if and only if the network just restarted
  /// after an upgrade and has not yet done the post-upgrade work.
  public var postUpgradeWorkDone: Bool {
    get {return _storage._postUpgradeWorkDone}
    set {_uniqueStorage()._postUpgradeWorkDone = newValue}
  }

  ///*
  /// A version describing the version of application software.
  /// <p>
  /// This SHALL be the software version that created this block.
  public var creationSoftwareVersion: Proto_SemanticVersion {
    get {return _storage._creationSoftwareVersion ?? Proto_SemanticVersion()}
    set {_uniqueStorage()._creationSoftwareVersion = newValue}
  }
  /// Returns true if `creationSoftwareVersion` has been explicitly set.
  public var hasCreationSoftwareVersion: Bool {return _storage._creationSoftwareVersion != nil}
  /// Clears the value of `creationSoftwareVersion`. Subsequent reads from it will return its default value.
  public mutating func clearCreationSoftwareVersion() {_uniqueStorage()._creationSoftwareVersion = nil}

  ///*
  /// The time stamp at which the last interval process was done.
  /// <p>
  /// This field SHALL hold the consensus time for the last time
  /// at which an interval of time-dependent events were processed.
  public var lastIntervalProcessTime: Proto_Timestamp {
    get {return _storage._lastIntervalProcessTime ?? Proto_Timestamp()}
    set {_uniqueStorage()._lastIntervalProcessTime = newValue}
  }
  /// Returns true if `lastIntervalProcessTime` has been explicitly set.
  public var hasLastIntervalProcessTime: Bool {return _storage._lastIntervalProcessTime != nil}
  /// Clears the value of `lastIntervalProcessTime`. Subsequent reads from it will return its default value.
  public mutating func clearLastIntervalProcessTime() {_uniqueStorage()._lastIntervalProcessTime = nil}

  ///*
  /// The time stamp at which the last user transaction was handled.
  /// <p>
  /// This field SHALL hold the consensus time for the last time
  /// at which a user transaction was handled.
  public var lastHandleTime: Proto_Timestamp {
    get {return _storage._lastHandleTime ?? Proto_Timestamp()}
    set {_uniqueStorage()._lastHandleTime = newValue}
  }
  /// Returns true if `lastHandleTime` has been explicitly set.
  public var hasLastHandleTime: Bool {return _storage._lastHandleTime != nil}
  /// Clears the value of `lastHandleTime`. Subsequent reads from it will return its default value.
  public mutating func clearLastHandleTime() {_uniqueStorage()._lastHandleTime = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "com.hedera.hapi.node.state.blockstream"

extension Com_Hedera_Hapi_Node_State_Blockstream_BlockStreamInfo: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".BlockStreamInfo"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "block_number"),
    2: .standard(proto: "block_time"),
    3: .standard(proto: "trailing_output_hashes"),
    4: .standard(proto: "trailing_block_hashes"),
    5: .standard(proto: "input_tree_root_hash"),
    6: .standard(proto: "start_of_block_state_hash"),
    7: .standard(proto: "num_preceding_output_items"),
    8: .standard(proto: "rightmost_preceding_output_tree_hashes"),
    9: .standard(proto: "block_end_time"),
    10: .standard(proto: "post_upgrade_work_done"),
    11: .standard(proto: "creation_software_version"),
    12: .standard(proto: "last_interval_process_time"),
    13: .standard(proto: "last_handle_time"),
  ]

  fileprivate class _StorageClass {
    var _blockNumber: UInt64 = 0
    var _blockTime: Proto_Timestamp? = nil
    var _trailingOutputHashes: Data = Data()
    var _trailingBlockHashes: Data = Data()
    var _inputTreeRootHash: Data = Data()
    var _startOfBlockStateHash: Data = Data()
    var _numPrecedingOutputItems: UInt32 = 0
    var _rightmostPrecedingOutputTreeHashes: [Data] = []
    var _blockEndTime: Proto_Timestamp? = nil
    var _postUpgradeWorkDone: Bool = false
    var _creationSoftwareVersion: Proto_SemanticVersion? = nil
    var _lastIntervalProcessTime: Proto_Timestamp? = nil
    var _lastHandleTime: Proto_Timestamp? = nil

    #if swift(>=5.10)
      // This property is used as the initial default value for new instances of the type.
      // The type itself is protecting the reference to its storage via CoW semantics.
      // This will force a copy to be made of this reference when the first mutation occurs;
      // hence, it is safe to mark this as `nonisolated(unsafe)`.
      static nonisolated(unsafe) let defaultInstance = _StorageClass()
    #else
      static let defaultInstance = _StorageClass()
    #endif

    private init() {}

    init(copying source: _StorageClass) {
      _blockNumber = source._blockNumber
      _blockTime = source._blockTime
      _trailingOutputHashes = source._trailingOutputHashes
      _trailingBlockHashes = source._trailingBlockHashes
      _inputTreeRootHash = source._inputTreeRootHash
      _startOfBlockStateHash = source._startOfBlockStateHash
      _numPrecedingOutputItems = source._numPrecedingOutputItems
      _rightmostPrecedingOutputTreeHashes = source._rightmostPrecedingOutputTreeHashes
      _blockEndTime = source._blockEndTime
      _postUpgradeWorkDone = source._postUpgradeWorkDone
      _creationSoftwareVersion = source._creationSoftwareVersion
      _lastIntervalProcessTime = source._lastIntervalProcessTime
      _lastHandleTime = source._lastHandleTime
    }
  }

  fileprivate mutating func _uniqueStorage() -> _StorageClass {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _StorageClass(copying: _storage)
    }
    return _storage
  }

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    _ = _uniqueStorage()
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      while let fieldNumber = try decoder.nextFieldNumber() {
        // The use of inline closures is to circumvent an issue where the compiler
        // allocates stack space for every case branch when no optimizations are
        // enabled. https://github.com/apple/swift-protobuf/issues/1034
        switch fieldNumber {
        case 1: try { try decoder.decodeSingularUInt64Field(value: &_storage._blockNumber) }()
        case 2: try { try decoder.decodeSingularMessageField(value: &_storage._blockTime) }()
        case 3: try { try decoder.decodeSingularBytesField(value: &_storage._trailingOutputHashes) }()
        case 4: try { try decoder.decodeSingularBytesField(value: &_storage._trailingBlockHashes) }()
        case 5: try { try decoder.decodeSingularBytesField(value: &_storage._inputTreeRootHash) }()
        case 6: try { try decoder.decodeSingularBytesField(value: &_storage._startOfBlockStateHash) }()
        case 7: try { try decoder.decodeSingularUInt32Field(value: &_storage._numPrecedingOutputItems) }()
        case 8: try { try decoder.decodeRepeatedBytesField(value: &_storage._rightmostPrecedingOutputTreeHashes) }()
        case 9: try { try decoder.decodeSingularMessageField(value: &_storage._blockEndTime) }()
        case 10: try { try decoder.decodeSingularBoolField(value: &_storage._postUpgradeWorkDone) }()
        case 11: try { try decoder.decodeSingularMessageField(value: &_storage._creationSoftwareVersion) }()
        case 12: try { try decoder.decodeSingularMessageField(value: &_storage._lastIntervalProcessTime) }()
        case 13: try { try decoder.decodeSingularMessageField(value: &_storage._lastHandleTime) }()
        default: break
        }
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try withExtendedLifetime(_storage) { (_storage: _StorageClass) in
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every if/case branch local when no optimizations
      // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
      // https://github.com/apple/swift-protobuf/issues/1182
      if _storage._blockNumber != 0 {
        try visitor.visitSingularUInt64Field(value: _storage._blockNumber, fieldNumber: 1)
      }
      try { if let v = _storage._blockTime {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
      } }()
      if !_storage._trailingOutputHashes.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._trailingOutputHashes, fieldNumber: 3)
      }
      if !_storage._trailingBlockHashes.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._trailingBlockHashes, fieldNumber: 4)
      }
      if !_storage._inputTreeRootHash.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._inputTreeRootHash, fieldNumber: 5)
      }
      if !_storage._startOfBlockStateHash.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._startOfBlockStateHash, fieldNumber: 6)
      }
      if _storage._numPrecedingOutputItems != 0 {
        try visitor.visitSingularUInt32Field(value: _storage._numPrecedingOutputItems, fieldNumber: 7)
      }
      if !_storage._rightmostPrecedingOutputTreeHashes.isEmpty {
        try visitor.visitRepeatedBytesField(value: _storage._rightmostPrecedingOutputTreeHashes, fieldNumber: 8)
      }
      try { if let v = _storage._blockEndTime {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
      } }()
      if _storage._postUpgradeWorkDone != false {
        try visitor.visitSingularBoolField(value: _storage._postUpgradeWorkDone, fieldNumber: 10)
      }
      try { if let v = _storage._creationSoftwareVersion {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 11)
      } }()
      try { if let v = _storage._lastIntervalProcessTime {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 12)
      } }()
      try { if let v = _storage._lastHandleTime {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 13)
      } }()
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Com_Hedera_Hapi_Node_State_Blockstream_BlockStreamInfo, rhs: Com_Hedera_Hapi_Node_State_Blockstream_BlockStreamInfo) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._blockNumber != rhs_storage._blockNumber {return false}
        if _storage._blockTime != rhs_storage._blockTime {return false}
        if _storage._trailingOutputHashes != rhs_storage._trailingOutputHashes {return false}
        if _storage._trailingBlockHashes != rhs_storage._trailingBlockHashes {return false}
        if _storage._inputTreeRootHash != rhs_storage._inputTreeRootHash {return false}
        if _storage._startOfBlockStateHash != rhs_storage._startOfBlockStateHash {return false}
        if _storage._numPrecedingOutputItems != rhs_storage._numPrecedingOutputItems {return false}
        if _storage._rightmostPrecedingOutputTreeHashes != rhs_storage._rightmostPrecedingOutputTreeHashes {return false}
        if _storage._blockEndTime != rhs_storage._blockEndTime {return false}
        if _storage._postUpgradeWorkDone != rhs_storage._postUpgradeWorkDone {return false}
        if _storage._creationSoftwareVersion != rhs_storage._creationSoftwareVersion {return false}
        if _storage._lastIntervalProcessTime != rhs_storage._lastIntervalProcessTime {return false}
        if _storage._lastHandleTime != rhs_storage._lastHandleTime {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
