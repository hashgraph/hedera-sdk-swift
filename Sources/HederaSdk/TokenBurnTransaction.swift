import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class TokenBurnTransaction: Transaction {
  var tokenId: TokenId?
  var amount: UInt64?
  var serial: [Int64]?

  @discardableResult
  public func setAmount(_ amount: UInt64) -> Self {
    self.amount = amount
    return self
  }

  @discardableResult
  public func setTokenId(_ token: TokenId) -> Self {
    tokenId = token
    return self
  }

  @discardableResult
  public func setSerialNumber(_ s: Int64) -> Self {
    if var serial = serial {
      serial.append(s)
      return self
    }

    var serial = [Int64]()
    serial.append(s)
    self.serial = serial

    return self
  }

  @discardableResult
  public func setSerialNumbers(_ serial: [Int64]) -> Self {
    self.serial = serial

    return self
  }

  public func getAmount() -> UInt64? {
    amount
  }

  public func getTokenId() -> TokenId? {
    tokenId
  }

  public func getSerialNumbers() -> [Int64]? {
    serial
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setTokenId(TokenId(proto.tokenBurn.token))
    setAmount(proto.tokenBurn.amount)
    setSerialNumbers(proto.tokenBurn.serialNumbers)
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getToken().burnToken
  }

  func build() -> Proto_TokenBurnTransactionBody {
    var body = Proto_TokenBurnTransactionBody()

    if let tokenId = tokenId {
      body.token = tokenId.toProtobuf()
    }

    if let amount = amount {
      body.amount = amount
    }

    if let serial = serial {
      body.serialNumbers = serial
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.tokenBurn = build()
  }
}
