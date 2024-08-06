// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: contract_create.proto
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
/// Start a new smart contract instance. After the instance is created, the ContractID for it is in
/// the receipt, and can be retrieved by the Record or with a GetByKey query. The instance will run
/// the bytecode, either stored in a previously created file or in the transaction body itself for 
/// small contracts.
/// 
/// 
/// The constructor will be executed using the given amount of gas, and any unspent gas will be
/// refunded to the paying account. Constructor inputs come from the given constructorParameters.
///  - The instance will exist for autoRenewPeriod seconds. When that is reached, it will renew
///    itself for another autoRenewPeriod seconds by charging its associated cryptocurrency account
///    (which it creates here). If it has insufficient cryptocurrency to extend that long, it will
///    extend as long as it can. If its balance is zero, the instance will be deleted.
///
///  - A smart contract instance normally enforces rules, so "the code is law". For example, an
///    ERC-20 contract prevents a transfer from being undone without a signature by the recipient of
///    the transfer. This is always enforced if the contract instance was created with the adminKeys
///    being null. But for some uses, it might be desirable to create something like an ERC-20
///    contract that has a specific group of trusted individuals who can act as a "supreme court"
///    with the ability to override the normal operation, when a sufficient number of them agree to
///    do so. If adminKeys is not null, then they can sign a transaction that can change the state of
///    the smart contract in arbitrary ways, such as to reverse a transaction that violates some
///    standard of behavior that is not covered by the code itself. The admin keys can also be used
///    to change the autoRenewPeriod, and change the adminKeys field itself. The API currently does
///    not implement this ability. But it does allow the adminKeys field to be set and queried, and
///    will in the future implement such admin abilities for any instance that has a non-null
///    adminKeys.
///
///  - If this constructor stores information, it is charged gas to store it. There is a fee in hbars
///    to maintain that storage until the expiration time, and that fee is added as part of the
///    transaction fee.
///
///  - An entity (account, file, or smart contract instance) must be created in a particular realm.
///    If the realmID is left null, then a new realm will be created with the given admin key. If a
///    new realm has a null adminKey, then anyone can create/modify/delete entities in that realm.
///    But if an admin key is given, then any transaction to create/modify/delete an entity in that
///    realm must be signed by that key, though anyone can still call functions on smart contract
///    instances that exist in that realm. A realm ceases to exist when everything within it has
///    expired and no longer exists.
///
///  - The current API ignores shardID, realmID, and newRealmAdminKey, and creates everything in
///    shard 0 and realm 0, with a null key. Future versions of the API will support multiple realms
///    and multiple shards.
///
///  - The optional memo field can contain a string whose length is up to 100 bytes. That is the size
///    after Unicode NFD then UTF-8 conversion. This field can be used to describe the smart contract.
///    It could also be used for other purposes. One recommended purpose is to hold a hexadecimal
///    string that is the SHA-384 hash of a PDF file containing a human-readable legal contract. Then,
///    if the admin keys are the public keys of human arbitrators, they can use that legal document to
///    guide their decisions during a binding arbitration tribunal, convened to consider any changes
///    to the smart contract in the future. The memo field can only be changed using the admin keys.
///    If there are no admin keys, then it cannot be changed after the smart contract is created.
///
/// <b>Signing requirements:</b> If an admin key is set, it must sign the transaction. If an 
/// auto-renew account is set, its key must sign the transaction.
public struct Proto_ContractCreateTransactionBody {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///*
  /// There are two ways to specify the initcode of a ContractCreateTransction. If the initcode is
  /// large (> 5K) then it must be stored in a file as hex encoded ascii. If it is small then it may
  /// either be stored as a hex encoded file or as a binary encoded field as part of the transaciton.
  public var initcodeSource: OneOf_InitcodeSource? {
    get {return _storage._initcodeSource}
    set {_uniqueStorage()._initcodeSource = newValue}
  }

  ///*
  /// The file containing the smart contract initcode. A copy will be made and held by the
  /// contract instance, and have the same expiration time as the instance.
  public var fileID: Proto_FileID {
    get {
      if case .fileID(let v)? = _storage._initcodeSource {return v}
      return Proto_FileID()
    }
    set {_uniqueStorage()._initcodeSource = .fileID(newValue)}
  }

  ///*
  /// The bytes of the smart contract initcode. This is only useful if the smart contract init
  /// is less than the hedera transaction limit. In those cases fileID must be used.
  public var initcode: Data {
    get {
      if case .initcode(let v)? = _storage._initcodeSource {return v}
      return Data()
    }
    set {_uniqueStorage()._initcodeSource = .initcode(newValue)}
  }

  ///*
  /// the state of the instance and its fields can be modified arbitrarily if this key signs a
  /// transaction to modify it. If this is null, then such modifications are not possible, and
  /// there is no administrator that can override the normal operation of this smart contract
  /// instance. Note that if it is created with no admin keys, then there is no administrator to
  /// authorize changing the admin keys, so there can never be any admin keys for that instance.
  public var adminKey: Proto_Key {
    get {return _storage._adminKey ?? Proto_Key()}
    set {_uniqueStorage()._adminKey = newValue}
  }
  /// Returns true if `adminKey` has been explicitly set.
  public var hasAdminKey: Bool {return _storage._adminKey != nil}
  /// Clears the value of `adminKey`. Subsequent reads from it will return its default value.
  public mutating func clearAdminKey() {_uniqueStorage()._adminKey = nil}

  ///*
  /// gas to run the constructor
  public var gas: Int64 {
    get {return _storage._gas}
    set {_uniqueStorage()._gas = newValue}
  }

  ///*
  /// initial number of tinybars to put into the cryptocurrency account associated with and owned
  /// by the smart contract
  public var initialBalance: Int64 {
    get {return _storage._initialBalance}
    set {_uniqueStorage()._initialBalance = newValue}
  }

  ///*
  /// [Deprecated] ID of the account to which this account is proxy staked. If proxyAccountID is null, or is an
  /// invalid account, or is an account that isn't a node, then this account is automatically proxy
  /// staked to a node chosen by the network, but without earning payments. If the proxyAccountID
  /// account refuses to accept proxy staking , or if it is not currently running a node, then it
  /// will behave as if  proxyAccountID was null.
  public var proxyAccountID: Proto_AccountID {
    get {return _storage._proxyAccountID ?? Proto_AccountID()}
    set {_uniqueStorage()._proxyAccountID = newValue}
  }
  /// Returns true if `proxyAccountID` has been explicitly set.
  public var hasProxyAccountID: Bool {return _storage._proxyAccountID != nil}
  /// Clears the value of `proxyAccountID`. Subsequent reads from it will return its default value.
  public mutating func clearProxyAccountID() {_uniqueStorage()._proxyAccountID = nil}

  ///*
  /// the instance will charge its account every this many seconds to renew for this long
  public var autoRenewPeriod: Proto_Duration {
    get {return _storage._autoRenewPeriod ?? Proto_Duration()}
    set {_uniqueStorage()._autoRenewPeriod = newValue}
  }
  /// Returns true if `autoRenewPeriod` has been explicitly set.
  public var hasAutoRenewPeriod: Bool {return _storage._autoRenewPeriod != nil}
  /// Clears the value of `autoRenewPeriod`. Subsequent reads from it will return its default value.
  public mutating func clearAutoRenewPeriod() {_uniqueStorage()._autoRenewPeriod = nil}

  ///*
  /// parameters to pass to the constructor
  public var constructorParameters: Data {
    get {return _storage._constructorParameters}
    set {_uniqueStorage()._constructorParameters = newValue}
  }

  ///*
  /// shard in which to create this
  public var shardID: Proto_ShardID {
    get {return _storage._shardID ?? Proto_ShardID()}
    set {_uniqueStorage()._shardID = newValue}
  }
  /// Returns true if `shardID` has been explicitly set.
  public var hasShardID: Bool {return _storage._shardID != nil}
  /// Clears the value of `shardID`. Subsequent reads from it will return its default value.
  public mutating func clearShardID() {_uniqueStorage()._shardID = nil}

  ///*
  /// realm in which to create this (leave this null to create a new realm)
  public var realmID: Proto_RealmID {
    get {return _storage._realmID ?? Proto_RealmID()}
    set {_uniqueStorage()._realmID = newValue}
  }
  /// Returns true if `realmID` has been explicitly set.
  public var hasRealmID: Bool {return _storage._realmID != nil}
  /// Clears the value of `realmID`. Subsequent reads from it will return its default value.
  public mutating func clearRealmID() {_uniqueStorage()._realmID = nil}

  ///*
  /// if realmID is null, then this the admin key for the new realm that will be created
  public var newRealmAdminKey: Proto_Key {
    get {return _storage._newRealmAdminKey ?? Proto_Key()}
    set {_uniqueStorage()._newRealmAdminKey = newValue}
  }
  /// Returns true if `newRealmAdminKey` has been explicitly set.
  public var hasNewRealmAdminKey: Bool {return _storage._newRealmAdminKey != nil}
  /// Clears the value of `newRealmAdminKey`. Subsequent reads from it will return its default value.
  public mutating func clearNewRealmAdminKey() {_uniqueStorage()._newRealmAdminKey = nil}

  ///*
  /// the memo that was submitted as part of the contract (max 100 bytes)
  public var memo: String {
    get {return _storage._memo}
    set {_uniqueStorage()._memo = newValue}
  }

  ///*
  /// The maximum number of tokens that can be auto-associated with the contract.<br/>
  /// If this is less than or equal to `used_auto_associations`, or 0, then this contract
  /// MUST manually associate with a token before transacting in that token.<br/>
  /// This value MAY also be `-1` to indicate no limit.<br/>
  /// This value MUST NOT be less than `-1`.<br/>
  /// By default this value is 0 for contracts.
  public var maxAutomaticTokenAssociations: Int32 {
    get {return _storage._maxAutomaticTokenAssociations}
    set {_uniqueStorage()._maxAutomaticTokenAssociations = newValue}
  }

  ///*
  /// An account to charge for auto-renewal of this contract. If not set, or set to an
  /// account with zero hbar balance, the contract's own hbar balance will be used to
  /// cover auto-renewal fees.
  public var autoRenewAccountID: Proto_AccountID {
    get {return _storage._autoRenewAccountID ?? Proto_AccountID()}
    set {_uniqueStorage()._autoRenewAccountID = newValue}
  }
  /// Returns true if `autoRenewAccountID` has been explicitly set.
  public var hasAutoRenewAccountID: Bool {return _storage._autoRenewAccountID != nil}
  /// Clears the value of `autoRenewAccountID`. Subsequent reads from it will return its default value.
  public mutating func clearAutoRenewAccountID() {_uniqueStorage()._autoRenewAccountID = nil}

  ///*
  /// ID of the new account or node to which this contract is staking.
  public var stakedID: OneOf_StakedID? {
    get {return _storage._stakedID}
    set {_uniqueStorage()._stakedID = newValue}
  }

  ///*
  /// ID of the account to which this contract is staking.
  public var stakedAccountID: Proto_AccountID {
    get {
      if case .stakedAccountID(let v)? = _storage._stakedID {return v}
      return Proto_AccountID()
    }
    set {_uniqueStorage()._stakedID = .stakedAccountID(newValue)}
  }

  ///*
  /// ID of the node this contract is staked to.
  public var stakedNodeID: Int64 {
    get {
      if case .stakedNodeID(let v)? = _storage._stakedID {return v}
      return 0
    }
    set {_uniqueStorage()._stakedID = .stakedNodeID(newValue)}
  }

  ///*
  /// If true, the contract declines receiving a staking reward. The default value is false.
  public var declineReward: Bool {
    get {return _storage._declineReward}
    set {_uniqueStorage()._declineReward = newValue}
  }

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  ///*
  /// There are two ways to specify the initcode of a ContractCreateTransction. If the initcode is
  /// large (> 5K) then it must be stored in a file as hex encoded ascii. If it is small then it may
  /// either be stored as a hex encoded file or as a binary encoded field as part of the transaciton.
  public enum OneOf_InitcodeSource: Equatable {
    ///*
    /// The file containing the smart contract initcode. A copy will be made and held by the
    /// contract instance, and have the same expiration time as the instance.
    case fileID(Proto_FileID)
    ///*
    /// The bytes of the smart contract initcode. This is only useful if the smart contract init
    /// is less than the hedera transaction limit. In those cases fileID must be used.
    case initcode(Data)

  #if !swift(>=4.1)
    public static func ==(lhs: Proto_ContractCreateTransactionBody.OneOf_InitcodeSource, rhs: Proto_ContractCreateTransactionBody.OneOf_InitcodeSource) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.fileID, .fileID): return {
        guard case .fileID(let l) = lhs, case .fileID(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.initcode, .initcode): return {
        guard case .initcode(let l) = lhs, case .initcode(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  ///*
  /// ID of the new account or node to which this contract is staking.
  public enum OneOf_StakedID: Equatable {
    ///*
    /// ID of the account to which this contract is staking.
    case stakedAccountID(Proto_AccountID)
    ///*
    /// ID of the node this contract is staked to.
    case stakedNodeID(Int64)

  #if !swift(>=4.1)
    public static func ==(lhs: Proto_ContractCreateTransactionBody.OneOf_StakedID, rhs: Proto_ContractCreateTransactionBody.OneOf_StakedID) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.stakedAccountID, .stakedAccountID): return {
        guard case .stakedAccountID(let l) = lhs, case .stakedAccountID(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.stakedNodeID, .stakedNodeID): return {
        guard case .stakedNodeID(let l) = lhs, case .stakedNodeID(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  public init() {}

  fileprivate var _storage = _StorageClass.defaultInstance
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Proto_ContractCreateTransactionBody: @unchecked Sendable {}
extension Proto_ContractCreateTransactionBody.OneOf_InitcodeSource: @unchecked Sendable {}
extension Proto_ContractCreateTransactionBody.OneOf_StakedID: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "proto"

extension Proto_ContractCreateTransactionBody: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ContractCreateTransactionBody"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "fileID"),
    16: .same(proto: "initcode"),
    3: .same(proto: "adminKey"),
    4: .same(proto: "gas"),
    5: .same(proto: "initialBalance"),
    6: .same(proto: "proxyAccountID"),
    8: .same(proto: "autoRenewPeriod"),
    9: .same(proto: "constructorParameters"),
    10: .same(proto: "shardID"),
    11: .same(proto: "realmID"),
    12: .same(proto: "newRealmAdminKey"),
    13: .same(proto: "memo"),
    14: .standard(proto: "max_automatic_token_associations"),
    15: .standard(proto: "auto_renew_account_id"),
    17: .standard(proto: "staked_account_id"),
    18: .standard(proto: "staked_node_id"),
    19: .standard(proto: "decline_reward"),
  ]

  fileprivate class _StorageClass {
    var _initcodeSource: Proto_ContractCreateTransactionBody.OneOf_InitcodeSource?
    var _adminKey: Proto_Key? = nil
    var _gas: Int64 = 0
    var _initialBalance: Int64 = 0
    var _proxyAccountID: Proto_AccountID? = nil
    var _autoRenewPeriod: Proto_Duration? = nil
    var _constructorParameters: Data = Data()
    var _shardID: Proto_ShardID? = nil
    var _realmID: Proto_RealmID? = nil
    var _newRealmAdminKey: Proto_Key? = nil
    var _memo: String = String()
    var _maxAutomaticTokenAssociations: Int32 = 0
    var _autoRenewAccountID: Proto_AccountID? = nil
    var _stakedID: Proto_ContractCreateTransactionBody.OneOf_StakedID?
    var _declineReward: Bool = false

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
      _initcodeSource = source._initcodeSource
      _adminKey = source._adminKey
      _gas = source._gas
      _initialBalance = source._initialBalance
      _proxyAccountID = source._proxyAccountID
      _autoRenewPeriod = source._autoRenewPeriod
      _constructorParameters = source._constructorParameters
      _shardID = source._shardID
      _realmID = source._realmID
      _newRealmAdminKey = source._newRealmAdminKey
      _memo = source._memo
      _maxAutomaticTokenAssociations = source._maxAutomaticTokenAssociations
      _autoRenewAccountID = source._autoRenewAccountID
      _stakedID = source._stakedID
      _declineReward = source._declineReward
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
        case 1: try {
          var v: Proto_FileID?
          var hadOneofValue = false
          if let current = _storage._initcodeSource {
            hadOneofValue = true
            if case .fileID(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._initcodeSource = .fileID(v)
          }
        }()
        case 3: try { try decoder.decodeSingularMessageField(value: &_storage._adminKey) }()
        case 4: try { try decoder.decodeSingularInt64Field(value: &_storage._gas) }()
        case 5: try { try decoder.decodeSingularInt64Field(value: &_storage._initialBalance) }()
        case 6: try { try decoder.decodeSingularMessageField(value: &_storage._proxyAccountID) }()
        case 8: try { try decoder.decodeSingularMessageField(value: &_storage._autoRenewPeriod) }()
        case 9: try { try decoder.decodeSingularBytesField(value: &_storage._constructorParameters) }()
        case 10: try { try decoder.decodeSingularMessageField(value: &_storage._shardID) }()
        case 11: try { try decoder.decodeSingularMessageField(value: &_storage._realmID) }()
        case 12: try { try decoder.decodeSingularMessageField(value: &_storage._newRealmAdminKey) }()
        case 13: try { try decoder.decodeSingularStringField(value: &_storage._memo) }()
        case 14: try { try decoder.decodeSingularInt32Field(value: &_storage._maxAutomaticTokenAssociations) }()
        case 15: try { try decoder.decodeSingularMessageField(value: &_storage._autoRenewAccountID) }()
        case 16: try {
          var v: Data?
          try decoder.decodeSingularBytesField(value: &v)
          if let v = v {
            if _storage._initcodeSource != nil {try decoder.handleConflictingOneOf()}
            _storage._initcodeSource = .initcode(v)
          }
        }()
        case 17: try {
          var v: Proto_AccountID?
          var hadOneofValue = false
          if let current = _storage._stakedID {
            hadOneofValue = true
            if case .stakedAccountID(let m) = current {v = m}
          }
          try decoder.decodeSingularMessageField(value: &v)
          if let v = v {
            if hadOneofValue {try decoder.handleConflictingOneOf()}
            _storage._stakedID = .stakedAccountID(v)
          }
        }()
        case 18: try {
          var v: Int64?
          try decoder.decodeSingularInt64Field(value: &v)
          if let v = v {
            if _storage._stakedID != nil {try decoder.handleConflictingOneOf()}
            _storage._stakedID = .stakedNodeID(v)
          }
        }()
        case 19: try { try decoder.decodeSingularBoolField(value: &_storage._declineReward) }()
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
      try { if case .fileID(let v)? = _storage._initcodeSource {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
      } }()
      try { if let v = _storage._adminKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
      } }()
      if _storage._gas != 0 {
        try visitor.visitSingularInt64Field(value: _storage._gas, fieldNumber: 4)
      }
      if _storage._initialBalance != 0 {
        try visitor.visitSingularInt64Field(value: _storage._initialBalance, fieldNumber: 5)
      }
      try { if let v = _storage._proxyAccountID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
      } }()
      try { if let v = _storage._autoRenewPeriod {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 8)
      } }()
      if !_storage._constructorParameters.isEmpty {
        try visitor.visitSingularBytesField(value: _storage._constructorParameters, fieldNumber: 9)
      }
      try { if let v = _storage._shardID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 10)
      } }()
      try { if let v = _storage._realmID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 11)
      } }()
      try { if let v = _storage._newRealmAdminKey {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 12)
      } }()
      if !_storage._memo.isEmpty {
        try visitor.visitSingularStringField(value: _storage._memo, fieldNumber: 13)
      }
      if _storage._maxAutomaticTokenAssociations != 0 {
        try visitor.visitSingularInt32Field(value: _storage._maxAutomaticTokenAssociations, fieldNumber: 14)
      }
      try { if let v = _storage._autoRenewAccountID {
        try visitor.visitSingularMessageField(value: v, fieldNumber: 15)
      } }()
      try { if case .initcode(let v)? = _storage._initcodeSource {
        try visitor.visitSingularBytesField(value: v, fieldNumber: 16)
      } }()
      switch _storage._stakedID {
      case .stakedAccountID?: try {
        guard case .stakedAccountID(let v)? = _storage._stakedID else { preconditionFailure() }
        try visitor.visitSingularMessageField(value: v, fieldNumber: 17)
      }()
      case .stakedNodeID?: try {
        guard case .stakedNodeID(let v)? = _storage._stakedID else { preconditionFailure() }
        try visitor.visitSingularInt64Field(value: v, fieldNumber: 18)
      }()
      case nil: break
      }
      if _storage._declineReward != false {
        try visitor.visitSingularBoolField(value: _storage._declineReward, fieldNumber: 19)
      }
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Proto_ContractCreateTransactionBody, rhs: Proto_ContractCreateTransactionBody) -> Bool {
    if lhs._storage !== rhs._storage {
      let storagesAreEqual: Bool = withExtendedLifetime((lhs._storage, rhs._storage)) { (_args: (_StorageClass, _StorageClass)) in
        let _storage = _args.0
        let rhs_storage = _args.1
        if _storage._initcodeSource != rhs_storage._initcodeSource {return false}
        if _storage._adminKey != rhs_storage._adminKey {return false}
        if _storage._gas != rhs_storage._gas {return false}
        if _storage._initialBalance != rhs_storage._initialBalance {return false}
        if _storage._proxyAccountID != rhs_storage._proxyAccountID {return false}
        if _storage._autoRenewPeriod != rhs_storage._autoRenewPeriod {return false}
        if _storage._constructorParameters != rhs_storage._constructorParameters {return false}
        if _storage._shardID != rhs_storage._shardID {return false}
        if _storage._realmID != rhs_storage._realmID {return false}
        if _storage._newRealmAdminKey != rhs_storage._newRealmAdminKey {return false}
        if _storage._memo != rhs_storage._memo {return false}
        if _storage._maxAutomaticTokenAssociations != rhs_storage._maxAutomaticTokenAssociations {return false}
        if _storage._autoRenewAccountID != rhs_storage._autoRenewAccountID {return false}
        if _storage._stakedID != rhs_storage._stakedID {return false}
        if _storage._declineReward != rhs_storage._declineReward {return false}
        return true
      }
      if !storagesAreEqual {return false}
    }
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
