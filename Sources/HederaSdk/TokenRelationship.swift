import Foundation
import HederaProtoServices

extension Bool {
  init?(_ proto: Proto_TokenKycStatus) {
    switch proto {
    case .granted:
      self.init(true)
      break
    case .revoked:
      self.init(false)
      break
    default:
      return nil
    }
  }
}

extension Bool {
  init?(_ proto: Proto_TokenFreezeStatus) {
    switch proto {
    case .frozen:
      self.init(true)
      break
    case .unfrozen:
      self.init(false)
      break
    default:
      return nil
    }
  }
}

public final class TokenRelationship {
  public let tokenId: TokenId
  public let symbol: String
  public let balance: UInt64
  public let kycStatus: Bool?
  public let freezeStatus: Bool?

  init(tokenId: TokenId, symbol: String, balance: UInt64, kycStatus: Bool?, freezeStatus: Bool?) {
    self.tokenId = tokenId
    self.symbol = symbol
    self.balance = balance
    self.kycStatus = kycStatus
    self.freezeStatus = freezeStatus
  }
}

extension TokenRelationship: ProtobufConvertible {
  public convenience init?(_ proto: Proto_TokenRelationship) {
    self.init(
      tokenId: TokenId(proto.tokenID),
      symbol: proto.symbol,
      balance: proto.balance,
      kycStatus: Bool(proto.kycStatus),
      freezeStatus: Bool(proto.freezeStatus)
    )
  }

  public func toProtobuf() -> Proto_TokenRelationship {
    var proto = Proto_TokenRelationship()
    proto.tokenID = tokenId.toProtobuf()
    proto.symbol = symbol
    proto.balance = balance
    proto.kycStatus = kycStatus.map { $0 ? .granted : .revoked } ?? .kycNotApplicable
    proto.freezeStatus = freezeStatus.map { $0 ? .frozen : .unfrozen } ?? .freezeNotApplicable
    return proto
  }
}
