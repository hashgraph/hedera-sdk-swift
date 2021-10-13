import Foundation
import HederaProtoServices

public final class AccountInfo {
  public let accountId: AccountId?
  public let contractAccountId: String
  public let isDeleted: Bool
  public let proxyAccountId: AccountId?
  public let proxyReceived: Hbar
  //  public let key: Key
  public let balance: Hbar
  public let isReceiverSignatureRequired: Bool
  public let expirationTime: Date?
  public let autoRenewPeriod: TimeInterval?
  public let tokenRelationships: [TokenId: TokenRelationship]
  public let accountMemo: String
  public let ownedNfts: UInt64

  init(
    accountId: AccountId?, contractAccountId: String, isDeleted: Bool, proxyAccountId: AccountId?,
    proxyReceived: Hbar, balance: Hbar,
    isReceiverSignatureRequired: Bool, expirationTime: Date?, autoRenewPeriod: TimeInterval?,
    tokenRelationships: [TokenId: TokenRelationship], accountMemo: String, ownedNfts: UInt64
  ) {
    self.accountId = accountId
    self.contractAccountId = contractAccountId
    self.isDeleted = isDeleted
    self.proxyAccountId = proxyAccountId
    self.proxyReceived = proxyReceived
    self.balance = balance
    self.isReceiverSignatureRequired = isReceiverSignatureRequired
    self.expirationTime = expirationTime
    self.autoRenewPeriod = autoRenewPeriod
    self.tokenRelationships = tokenRelationships
    self.accountMemo = accountMemo
    self.ownedNfts = ownedNfts
  }
}

extension AccountInfo: ProtobufConvertible {
  public convenience init?(_ proto: Proto_CryptoGetInfoResponse.AccountInfo) {
    self.init(
      accountId: proto.hasAccountID ? AccountId(proto.accountID) : nil,
      contractAccountId: proto.contractAccountID,
      isDeleted: proto.deleted,
      proxyAccountId: proto.hasProxyAccountID ? AccountId(proto.proxyAccountID) : nil,
      proxyReceived: Hbar(proto.proxyReceived),
      balance: Hbar(proto.balance),
      isReceiverSignatureRequired: proto.receiverSigRequired,
      expirationTime: proto.hasExpirationTime ? Date(proto.expirationTime) : nil,
      autoRenewPeriod: proto.hasAutoRenewPeriod ? TimeInterval(proto.autoRenewPeriod) : nil,
      tokenRelationships: Dictionary(
        uniqueKeysWithValues: proto.tokenRelationships.map {
          (TokenId($0.tokenID), TokenRelationship($0)!)
        }),
      accountMemo: proto.memo,
      ownedNfts: UInt64(proto.ownedNfts)
    )
  }

  public func toProtobuf() -> Proto_CryptoGetInfoResponse.AccountInfo {
    var proto = Proto_CryptoGetInfoResponse.AccountInfo()
    proto.contractAccountID = contractAccountId
    proto.deleted = isDeleted
    proto.proxyReceived = Int64(proxyReceived.toProtobuf())
    proto.balance = balance.toProtobuf()
    proto.receiverSigRequired = isReceiverSignatureRequired
    proto.memo = accountMemo
    proto.tokenRelationships = tokenRelationships.map { $0.value.toProtobuf() }
    proto.ownedNfts = Int64(ownedNfts)

    if let accountId = accountId {
      proto.accountID = accountId.toProtobuf()
    }

    if let proxyAccountId = proxyAccountId {
      proto.proxyAccountID = proxyAccountId.toProtobuf()
    }

    if let expirationTime = expirationTime {
      proto.expirationTime = expirationTime.toProtobuf()
    }

    if let autoRenewPeriod = autoRenewPeriod {
      proto.autoRenewPeriod = autoRenewPeriod.toProtobuf()
    }

    return proto
  }
}

extension AccountInfo: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    """
    accountId: \(String(describing: accountId)),
    contractAccountId: \(contractAccountId),
    isDeleted: \(isDeleted),
    proxyAccountId: \(String(describing: proxyAccountId)),
    balance: \(balance),
    isReceiverSignatureRequired: \(isReceiverSignatureRequired),
    expirationTime: \(String(describing: expirationTime)),
    autoRenewPeriod: \(String(describing: autoRenewPeriod)),
    tokenRelationships: \(tokenRelationships.map { $0.value.description }),
    accountMemo: \(accountMemo),
    ownedNfts: \(ownedNfts),
    """
  }
  public var debugDescription: String {
    description
  }
}
