// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: node_stake_update.proto
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
/// Updates the staking info at the end of staking period to indicate new staking period has started.
public struct Proto_NodeStakeUpdateTransactionBody: @unchecked Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// Time and date of the end of the staking period that is ending
  public var endOfStakingPeriod: Proto_Timestamp {
    get {return _storage._endOfStakingPeriod ?? Proto_Timestamp()}
    set {_uniqueStorage()._endOfStakingPeriod = newValue}
  }
  /// Returns true if `endOfStakingPeriod` has been explicitly set.
  public var hasEndOfStakingPeriod: Bool {return _storage._endOfStakingPeriod != nil}
  /// Clears the value of `endOfStakingPeriod`. Subsequent reads from it will return its default value.
  public mutating func clearEndOfStakingPeriod() {_uniqueStorage()._endOfStakingPeriod = nil}

  ///*
  /// Staking info of each node at the beginning of the new staking period
  public var nodeStake: [Proto_NodeStake] {
    get {return _storage._nodeStake}
    set {_uniqueStorage()._nodeStake = newValue}
  }

  ///*
  /// The maximum reward rate, in tinybars per whole hbar, that any account could receive in this
  /// staking period.
  public var maxStakingRewardRatePerHbar: Int64 {
    get {return _storage._maxStakingRewardRatePerHbar}
    set {_uniqueStorage()._maxStakingRewardRatePerHbar = newValue}
  }

  ///*
  /// The fraction of the network and service fees paid to the node reward account 0.0.801.
  public var nodeRewardFeeFraction: Proto_Fraction {
    get {return _storage._nodeRewardFeeFraction ?? Proto_Fraction()}
    set {_uniqueStorage()._nodeRewardFeeFraction = newValue}
  }
  /// Returns true if `nodeRewardFeeFraction` has been explicitly set.
  public var hasNodeRewardFeeFraction: Bool {return _storage._nodeRewardFeeFraction != nil}
  /// Clears the value of `nodeRewardFeeFraction`. Subsequent reads from it will return its default value.
  public mutating func clearNodeRewardFeeFraction() {_uniqueStorage()._nodeRewardFeeFraction = nil}

  ///*
  /// The maximum number of trailing periods for which a user can collect rewards. For example, if this
  /// is 365 with a UTC calendar day period, then users must collect rewards at least once per calendar
  /// year to avoid missing any value.
  public var stakingPeriodsStored: Int64 {
    get {return _storage._stakingPeriodsStored}
    set {_uniqueStorage()._stakingPeriodsStored = newValue}
  }

  ///*
  /// The number of minutes in a staking period. Note for the special case of 1440 minutes, periods are 
  /// treated as UTC calendar days, rather than repeating 1440 minute periods left-aligned at the epoch.
  public var stakingPeriod: Int64 {
    get {return _storage._stakingPeriod}
    set {_uniqueStorage()._stakingPeriod = newValue}
  }

  ///*
  /// The fraction of the network and service fees paid to the staking reward account 0.0.800.
  public var stakingRewardFeeFraction: Proto_Fraction {
    get {return _storage._stakingRewardFeeFraction ?? Proto_Fraction()}
    set {_uniqueStorage()._stakingRewardFeeFraction = newValue}
  }
  /// Returns true if `stakingRewardFeeFraction` has been explicitly set.
  public var hasStakingRewardFeeFraction: Bool {return _storage._stakingRewardFeeFraction != nil}
  /// Clears the value of `stakingRewardFeeFraction`. Subsequent reads from it will return its default value.
  public mutating func clearStakingRewardFeeFraction() {_uniqueStorage()._stakingRewardFeeFraction = nil}

  ///*
  /// The minimum balance of staking reward account 0.0.800 required to active rewards.
  public var stakingStartThreshold: Int64 {
    get {return _storage._stakingStartThreshold}
    set {_uniqueStorage()._stakingStartThreshold = newValue}
  }

  ///*
  /// (DEPRECATED) The maximum total number of tinybars to be distributed as staking rewards in the 
  /// ending period. Please consult the max_total_reward field instead.
  ///
  /// NOTE: This field was marked as deprecated in the .proto file.
  public var stakingRewardRate: Int64 {
    get {return _storage._stakingRewardRate}
    set {_uniqueStorage()._stakingRewardRate = newValue}
  }

  ///*
  /// The amount of the staking reward funds (account 0.0.800) reserved to pay pending rewards that 
  /// have been earned but not collected.
  public var reservedStakingRewards: Int64 {
    get {return _storage._reservedStakingRewards}
    set {_uniqueStorage()._reservedStakingRewards = newValue}
  }

  ///*
  /// The unreserved balance of account 0.0.800 at the close of the just-ending period; this value is 
  /// used to compute the HIP-782 balance ratio.
  public var unreservedStakingRewardBalance: Int64 {
    get {return _storage._unreservedStakingRewardBalance}
    set {_uniqueStorage()._unreservedStakingRewardBalance = newValue}
  }

  ///*
  /// The unreserved tinybar balance of account 0.0.800 required to achieve the maximum per-hbar reward 
  /// rate in any period; please see HIP-782 for details.
  public var rewardBalanceThreshold: Int64 {
    get {return _storage._rewardBalanceThreshold}
    set {_uniqueStorage()._rewardBalanceThreshold = newValue}
  }

  ///*
  /// The maximum amount of tinybar that can be staked for reward while still achieving the maximum 
  /// per-hbar reward rate in any period; please see HIP-782 for details.
  public var maxStakeRewarded: Int64 {
    get {return _storage._maxStakeRewarded}
    set {_uniqueStorage()._maxStakeRewarded = newValue}
  }

  ///*
  /// The maximum total tinybars that could be paid as staking rewards in the ending period, after 
  /// applying the settings for the 0.0.800 balance threshold and the maximum stake rewarded. This
  /// field replaces the deprecated field staking_reward_rate. It is only for convenience, since a 
  /// mirror node could also calculate its value by iterating the node_stake list and summing 
  /// stake_rewarded fields; then multiplying this sum by the max_staking_reward_rate_per_hbar.
  public var maxTotalReward: Int64 {
    get {return _storage._maxTotalReward}
    set {_uniqueStorage()._maxTotalReward = newValue}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

///*
/// Staking info for each node at the end of a staking period.
public struct Proto_NodeStake: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// The maximum stake (rewarded or not rewarded) this node can have as consensus weight. If its stake to
  /// reward is above this maximum at the start of a period, then accounts staking to the node in that 
  /// period will be rewarded at a lower rate scaled by (maxStake / stakeRewardStart).
  public var maxStake: Int64 = 0

  ///*
  /// The minimum stake (rewarded or not rewarded) this node must reach before having non-zero consensus weight.
  /// If its total stake is below this minimum at the start of a period, then accounts staking to the node in 
  /// that period will receive no rewards.
  public var minStake: Int64 = 0

  ///*
  /// The id of this node.
  public var nodeID: Int64 = 0

  ///*
  /// The reward rate _per whole hbar_ that was staked to this node with declineReward=false from the start of 
  /// the staking period that is ending. 
  public var rewardRate: Int64 = 0

  ///*
  /// Consensus weight of this node for the new staking period.
  public var stake: Int64 = 0

  ///*
  /// Total of (balance + stakedToMe) for all accounts staked to this node with declineReward=true, at the 
  /// beginning of the new staking period.
  public var stakeNotRewarded: Int64 = 0

  ///*
  /// Total of (balance + stakedToMe) for all accounts staked to this node with declineReward=false, at the 
  /// beginning of the new staking period.
  public var stakeRewarded: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_NodeStakeUpdateTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NodeStakeUpdateTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "end_of_staking_period"),
    2: .standard(proto: "node_stake"),
    3: .standard(proto: "max_staking_reward_rate_per_hbar"),
    4: .standard(proto: "node_reward_fee_fraction"),
    5: .standard(proto: "staking_periods_stored"),
    6: .standard(proto: "staking_period"),
    7: .standard(proto: "staking_reward_fee_fraction"),
    8: .standard(proto: "staking_start_threshold"),
    9: .standard(proto: "staking_reward_rate"),
    10: .standard(proto: "reserved_staking_rewards"),
    11: .standard(proto: "unreserved_staking_reward_balance"),
    12: .standard(proto: "reward_balance_threshold"),
    13: .standard(proto: "max_stake_rewarded"),
    14: .standard(proto: "max_total_reward"),
  ]

  fileprivate class _StorageClass {
    var _endOfStakingPeriod: Proto_Timestamp? = nil
    var _nodeStake: [Proto_NodeStake] = []
    var _maxStakingRewardRatePerHbar: Int64 = 0
    var _nodeRewardFeeFraction: Proto_Fraction? = nil
    var _stakingPeriodsStored: Int64 = 0
    var _stakingPeriod: Int64 = 0
    var _stakingRewardFeeFraction: Proto_Fraction? = nil
    var _stakingStartThreshold: Int64 = 0
    var _stakingRewardRate: Int64 = 0
    var _reservedStakingRewards: Int64 = 0
    var _unreservedStakingRewardBalance: Int64 = 0
    var _rewardBalanceThreshold: Int64 = 0
    var _maxStakeRewarded: Int64 = 0
    var _maxTotalReward: Int64 = 0

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
      _endOfStakingPeriod = source._endOfStakingPeriod
      _nodeStake = source._nodeStake
      _maxStakingRewardRatePerHbar = source._maxStakingRewardRatePerHbar
      _nodeRewardFeeFraction = source._nodeRewardFeeFraction
      _stakingPeriodsStored = source._stakingPeriodsStored
      _stakingPeriod = source._stakingPeriod
      _stakingRewardFeeFraction = source._stakingRewardFeeFraction
      _stakingStartThreshold = source._stakingStartThreshold
      _stakingRewardRate = source._stakingRewardRate
      _reservedStakingRewards = source._reservedStakingRewards
      _unreservedStakingRewardBalance = source._unreservedStakingRewardBalance
      _rewardBalanceThreshold = source._rewardBalanceThreshold
      _maxStakeRewarded = source._maxStakeRewarded
      _maxTotalReward = source._maxTotalReward
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
        case 1: try { try decoder.decodeSingularMessageField(value: &_storage._endOfStakingPeriod) }()
        case 2: try { try decoder.decodeRepeatedMessageField(value: &_storage._nodeStake) }()
        case 3: try { try decoder.decodeSingularInt64Field(value: &_storage._maxStakingRewardRatePerHbar) }()
        case 4: try { try decoder.decodeSingularMessageField(value: &_storage._nodeRewardFeeFraction) }()
        case 5: try { try decoder.decodeSingularInt64Field(value: &_storage._stakingPeriodsStored) }()
        case 6: try { try decoder.decodeSingularInt64Field(value: &_storage._stakingPeriod) }()
        case 7: try { try decoder.decodeSingularMessageField(value: &_storage._stakingRewardFeeFraction) }()
        case 8: try { try decoder.decodeSingularInt64Field(value: &_storage._stakingStartThreshold) }()
        case 9: try { try decoder.decodeSingularInt64Field(value: &_storage._stakingRewardRate) }()
        case 10: try { try decoder.decodeSingularInt64Field(value: &_storage._reservedStakingRewards) }()
        case 11: try { try decoder.decodeSingularInt64Field(value: &_storage._unreservedStakingRewardBalance) }()
        case 12: try { try decoder.decodeSingularInt64Field(value: &_storage._rewardBalanceThreshold) }()
        case 13: try { try decoder.decodeSingularInt64Field(value: &_storage._maxStakeRewarded) }()
        case 14: try { try decoder.decodeSingularInt64Field(value: &_storage._maxTotalReward) }()
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
      try { if let v = _storage._endOfStakingPeriod {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      } }()
      if !_storage._nodeStake.isEmpty {
        try visitor.visitRepeatedMessageField(value: _storage._nodeStake, fieldNumber: 2)
      }
      if _storage._maxStakingRewardRatePerHbar != 0 {
        try visitor.visitSingularInt64Field(value: _storage._maxStakingRewardRatePerHbar, fieldNumber: 3)
      }
      try { if let v = _storage._nodeRewardFeeFraction {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
      } }()
      if _storage._stakingPeriodsStored != 0 {
        try visitor.visitSingularInt64Field(value: _storage._stakingPeriodsStored, fieldNumber: 5)
      }
      if _storage._stakingPeriod != 0 {
        try visitor.visitSingularInt64Field(value: _storage._stakingPeriod, fieldNumber: 6)
      }
      try { if let v = _storage._stakingRewardFeeFraction {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 7)
      } }()
      if _storage._stakingStartThreshold != 0 {
        try visitor.visitSingularInt64Field(value: _storage._stakingStartThreshold, fieldNumber: 8)
      }
      if _storage._stakingRewardRate != 0 {
        try visitor.visitSingularInt64Field(value: _storage._stakingRewardRate, fieldNumber: 9)
      }
      if _storage._reservedStakingRewards != 0 {
        try visitor.visitSingularInt64Field(value: _storage._reservedStakingRewards, fieldNumber: 10)
      }
      if _storage._unreservedStakingRewardBalance != 0 {
        try visitor.visitSingularInt64Field(value: _storage._unreservedStakingRewardBalance, fieldNumber: 11)
      }
      if _storage._rewardBalanceThreshold != 0 {
        try visitor.visitSingularInt64Field(value: _storage._rewardBalanceThreshold, fieldNumber: 12)
      }
      if _storage._maxStakeRewarded != 0 {
        try visitor.visitSingularInt64Field(value: _storage._maxStakeRewarded, fieldNumber: 13)
      }
      if _storage._maxTotalReward != 0 {
        try visitor.visitSingularInt64Field(value: _storage._maxTotalReward, fieldNumber: 14)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_NodeStakeUpdateTransactionBody, rhs: Proto_NodeStakeUpdateTransactionBody) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._endOfStakingPeriod != rhs_storage._endOfStakingPeriod {return false}
        if _storage._nodeStake != rhs_storage._nodeStake {return false}
        if _storage._maxStakingRewardRatePerHbar != rhs_storage._maxStakingRewardRatePerHbar {return false}
        if _storage._nodeRewardFeeFraction != rhs_storage._nodeRewardFeeFraction {return false}
        if _storage._stakingPeriodsStored != rhs_storage._stakingPeriodsStored {return false}
        if _storage._stakingPeriod != rhs_storage._stakingPeriod {return false}
        if _storage._stakingRewardFeeFraction != rhs_storage._stakingRewardFeeFraction {return false}
        if _storage._stakingStartThreshold != rhs_storage._stakingStartThreshold {return false}
        if _storage._stakingRewardRate != rhs_storage._stakingRewardRate {return false}
        if _storage._reservedStakingRewards != rhs_storage._reservedStakingRewards {return false}
        if _storage._unreservedStakingRewardBalance != rhs_storage._unreservedStakingRewardBalance {return false}
        if _storage._rewardBalanceThreshold != rhs_storage._rewardBalanceThreshold {return false}
        if _storage._maxStakeRewarded != rhs_storage._maxStakeRewarded {return false}
        if _storage._maxTotalReward != rhs_storage._maxTotalReward {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Proto_NodeStake: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NodeStake"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "max_stake"),
    2: .standard(proto: "min_stake"),
    3: .standard(proto: "node_id"),
    4: .standard(proto: "reward_rate"),
    5: .same(proto: "stake"),
    6: .standard(proto: "stake_not_rewarded"),
    7: .standard(proto: "stake_rewarded"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.maxStake) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.minStake) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.nodeID) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.rewardRate) }()
      case 5: try { try decoder.decodeSingularInt64Field(value: &self.stake) }()
      case 6: try { try decoder.decodeSingularInt64Field(value: &self.stakeNotRewarded) }()
      case 7: try { try decoder.decodeSingularInt64Field(value: &self.stakeRewarded) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.maxStake != 0 {
      try visitor.visitSingularInt64Field(value: self.maxStake, fieldNumber: 1)
    }
    if self.minStake != 0 {
      try visitor.visitSingularInt64Field(value: self.minStake, fieldNumber: 2)
    }
    if self.nodeID != 0 {
      try visitor.visitSingularInt64Field(value: self.nodeID, fieldNumber: 3)
    }
    if self.rewardRate != 0 {
      try visitor.visitSingularInt64Field(value: self.rewardRate, fieldNumber: 4)
    }
    if self.stake != 0 {
      try visitor.visitSingularInt64Field(value: self.stake, fieldNumber: 5)
    }
    if self.stakeNotRewarded != 0 {
      try visitor.visitSingularInt64Field(value: self.stakeNotRewarded, fieldNumber: 6)
    }
    if self.stakeRewarded != 0 {
      try visitor.visitSingularInt64Field(value: self.stakeRewarded, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_NodeStake, rhs: Proto_NodeStake) -> Bool {
    if lhs.maxStake != rhs.maxStake {return false}
    if lhs.minStake != rhs.minStake {return false}
    if lhs.nodeID != rhs.nodeID {return false}
    if lhs.rewardRate != rhs.rewardRate {return false}
    if lhs.stake != rhs.stake {return false}
    if lhs.stakeNotRewarded != rhs.stakeNotRewarded {return false}
    if lhs.stakeRewarded != rhs.stakeRewarded {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
