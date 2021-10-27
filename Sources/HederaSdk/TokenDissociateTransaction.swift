import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class TokenDissociateTransaction: Transaction {
  var accountId: AccountId?
  var tokens: [TokenId] = []

  @discardableResult
  public func setAccountId(_ accountId: AccountId) -> Self {
    self.accountId = accountId
    return self
  }

  @discardableResult
  public func setTokenIds(_ tokens: [TokenId]) -> Self {
    self.tokens = tokens
    return self
  }

  public func getAccoundId() -> AccountId? {
    accountId
  }

  public func getTokenIds() -> [TokenId]? {
    tokens
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()
    var t = [TokenId]()
    if proto.tokenDissociate.tokens.count > 0 {
      for token in proto.tokenDissociate.tokens {
        t.append(TokenId(token))
      }
    }

    setAccountId(AccountId(proto.tokenDissociate.account))
    setTokenIds(t)
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getToken().dissociateTokens
  }

  func build() -> Proto_TokenDissociateTransactionBody {
    var body = Proto_TokenDissociateTransactionBody()

    if let accountId = accountId {
      body.account = accountId.toProtobuf()
    }

    var t = [Proto_TokenID]()
    for token in tokens {
      t.append(token.toProtobuf())
    }

    body.tokens = t

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.tokenDissociate = build()
  }
}
