import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class TokenCreateTransaction: Transaction {
  var treasuryAccountId: AccountId?
  var autoRenewAccountId: AccountId?
  var tokenName: String = ""
  var tokenMemo: String = ""
  var tokenSymbol: String = ""
  var decimals: UInt32 = 0
  var tokenSupplyType: TokenSupplyType?
  var tokenType: TokenType = TokenType.TokenTypeFungibleCommon
  var maxSupply: Int64 = 0
  var adminKey: Key?
  var kycKey: Key?
  var freezeKey: Key?
  var wipeKey: Key?
  var scheduleKey: Key?
  var supplyKey: Key?
  var pauseKey: Key?
  var initialSupply: UInt64 = 0
  var freezeDefault: Bool?
  var expirationTime: Date?
  var autoRenewPeriod: TimeInterval?

  @discardableResult
  public func setTreasuryAccountId(_ accountId: AccountId) -> Self {
    treasuryAccountId = accountId
    return self
  }

  @discardableResult
  public func setAutoRenewAccountId(_ accountId: AccountId) -> Self {
    autoRenewAccountId = accountId
    return self
  }

  @discardableResult
  public func setTokenName(_ name: String) -> Self {
    tokenName = name
    return self
  }

  @discardableResult
  public func setTokenMemo(_ memo: String) -> Self {
    tokenMemo = memo
    return self
  }

  @discardableResult
  public func setTokenSymbol(_ symbol: String) -> Self {
    tokenSymbol = symbol
    return self
  }

  @discardableResult
  public func setDecimals(_ decimals: UInt32) -> Self {
    self.decimals = decimals
    return self
  }

  @discardableResult
  public func setTokenSupplyType(_ supply: TokenSupplyType) -> Self {
    tokenSupplyType = supply
    return self
  }

  @discardableResult
  public func setTokenType(_ tokenType: TokenType) -> Self {
    self.tokenType = tokenType
    return self
  }

  @discardableResult
  public func setMaxSupply(_ maxSupply: Int64) -> Self {
    self.maxSupply = maxSupply
    return self
  }

  @discardableResult
  public func setAdminKey(_ key: Key) -> Self {
    adminKey = key
    return self
  }

  @discardableResult
  public func setKycKey(_ key: Key) -> Self {
    kycKey = key
    return self
  }

  @discardableResult
  public func setFreezeKey(_ key: Key) -> Self {
    freezeKey = key
    return self
  }

  @discardableResult
  public func setWipeKey(_ key: Key) -> Self {
    wipeKey = key
    return self
  }

  @discardableResult
  public func setScheduleKey(_ key: Key) -> Self {
    scheduleKey = key
    return self
  }

  @discardableResult
  public func setSupplyKey(_ key: Key) -> Self {
    supplyKey = key
    return self
  }

  @discardableResult
  public func setPauseKey(_ key: Key) -> Self {
    pauseKey = key
    return self
  }

  @discardableResult
  public func setInitialSupply(_ supply: UInt64) -> Self {
    initialSupply = supply
    return self
  }

  @discardableResult
  public func setFreezeDefault(_ freeze: Bool) -> Self {
    freezeDefault = freeze
    return self
  }

  @discardableResult
  public func setExpirationTime(_ time: Date) -> Self {
    expirationTime = time
    return self
  }

  @discardableResult
  public func setAutoRenewPeriod(_ autoRenewPeriod: TimeInterval) -> Self {
    self.autoRenewPeriod = autoRenewPeriod
    return self
  }

  public func getTreasuryAccountId() -> AccountId? {
    treasuryAccountId
  }

  public func getAutoRenewAccountId() -> AccountId? {
    autoRenewAccountId
  }

  public func getTokenName() -> String {
    tokenName
  }

  public func getTokenMemo() -> String {
    tokenMemo
  }

  public func setTokenSymbol() -> String {
    tokenSymbol
  }

  public func getDecimals() -> UInt32 {
    decimals
  }

  public func getTokenSupplyType() -> TokenSupplyType? {
    tokenSupplyType
  }

  public func getTokenType() -> TokenType {
    tokenType
  }

  public func getMaxSupply() -> Int64 {
    maxSupply
  }

  public func getAdminKey() -> Key? {
    adminKey
  }

  public func getKycKey() -> Key? {
    kycKey
  }

  public func getFreezeKey() -> Key? {
    freezeKey
  }

  public func getWipeKey() -> Key? {
    wipeKey
  }

  public func getScheduleKey() -> Key? {
    scheduleKey
  }

  public func getSupplyKey() -> Key? {
    supplyKey
  }

  public func getPauseKey() -> Key? {
    pauseKey
  }

  public func getInitialSupply() -> UInt64 {
    initialSupply
  }

  public func getFreezeDefault() -> Bool? {
    freezeDefault
  }

  public func getExpirationTime() -> Date? {
    expirationTime
  }

  public func getAutoRenewPeriod() -> TimeInterval? {
    autoRenewPeriod
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setTreasuryAccountId(AccountId(proto.tokenCreation.treasury))
    setAutoRenewAccountId(AccountId(proto.tokenCreation.autoRenewAccount))
    setTokenName(proto.tokenCreation.name)
    setTokenMemo(proto.tokenCreation.memo)
    setTokenSymbol(proto.tokenCreation.symbol)
    setTokenSupplyType(TokenSupplyType(rawValue: proto.tokenCreation.supplyType.rawValue)!)
    setTokenType(TokenType(rawValue: proto.tokenCreation.tokenType.rawValue)!)
    setMaxSupply(proto.tokenCreation.maxSupply)
    if proto.tokenCreation.hasAdminKey {
      setAdminKey(Key.fromProtobuf(proto.tokenCreation.adminKey)!)
    }
    if proto.tokenCreation.hasKycKey {
      setKycKey(Key.fromProtobuf(proto.tokenCreation.kycKey)!)
    }
    if proto.tokenCreation.hasFreezeKey {
      setFreezeKey(Key.fromProtobuf(proto.tokenCreation.freezeKey)!)
    }
    if proto.tokenCreation.hasWipeKey {
      setWipeKey(Key.fromProtobuf(proto.tokenCreation.wipeKey)!)
    }
    if proto.tokenCreation.hasSupplyKey {
      setSupplyKey(Key.fromProtobuf(proto.tokenCreation.supplyKey)!)
    }
    setInitialSupply(proto.tokenCreation.initialSupply)
    setFreezeDefault(proto.tokenCreation.freezeDefault)
    if proto.tokenCreation.hasExpiry {
      setExpirationTime(Date(proto.tokenCreation.expiry)!)
    }
    if proto.tokenCreation.hasAutoRenewPeriod {
      setAutoRenewPeriod(TimeInterval(proto.tokenCreation.autoRenewPeriod)!)
    }
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getToken().createToken
  }

  func build() -> Proto_TokenCreateTransactionBody {
    var body = Proto_TokenCreateTransactionBody()
    body.name = tokenName
    body.memo = tokenMemo
    body.symbol = tokenSymbol
    body.decimals = decimals
    body.tokenType = Proto_TokenType(rawValue: tokenType.rawValue)!
    body.maxSupply = maxSupply
    body.initialSupply = initialSupply

    if let treasuryAccountId = treasuryAccountId {
      body.treasury = treasuryAccountId.toProtobuf()
    }

    if let autoRenewAccountId = autoRenewAccountId {
      body.autoRenewAccount = autoRenewAccountId.toProtobuf()
    }

    if let tokenSupplyType = tokenSupplyType {
      body.supplyType = Proto_TokenSupplyType(rawValue: tokenSupplyType.rawValue)!
    }

    if let adminKey = adminKey {
      body.adminKey = adminKey.toProtobuf()
    }

    if let kycKey = kycKey {
      body.kycKey = kycKey.toProtobuf()
    }

    if let freezeKey = freezeKey {
      body.freezeKey = freezeKey.toProtobuf()
    }

    if let wipeKey = wipeKey {
      body.wipeKey = wipeKey.toProtobuf()
    }

    if let supplyKey = supplyKey {
      body.supplyKey = supplyKey.toProtobuf()
    }

    if let freezeDefault = freezeDefault {
      body.freezeDefault = freezeDefault
    }

    if let expirationTime = expirationTime {
      body.expiry = expirationTime.toProtobuf()
    }

    if let autoRenewPeriod = autoRenewPeriod {
      body.autoRenewPeriod = autoRenewPeriod.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.tokenCreation = build()
  }
}
