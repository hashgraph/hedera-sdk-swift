import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class TokenFreezeTransaction: Transaction {
  var tokenId: TokenId?
  var accountId: AccountId?

  @discardableResult
  public func setAccountId(_ accountId: AccountId) -> Self {
    self.accountId = accountId
    return self
  }

  @discardableResult
  public func setTokenId(_ token: TokenId) -> Self {
    tokenId = token
    return self
  }

  public func getAccoundId() -> AccountId? {
    accountId
  }

  public func getTokenId() -> TokenId? {
    tokenId
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setAccountId(AccountId(proto.tokenAssociate.account))
    setTokenId(TokenId(proto.tokenFreeze.token))
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getToken().freezeTokenAccount
  }

  func build() -> Proto_TokenFreezeAccountTransactionBody {
    var body = Proto_TokenFreezeAccountTransactionBody()

    if let accountId = accountId {
      body.account = accountId.toProtobuf()
    }

    if let tokenId = tokenId {
      body.token = tokenId.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.tokenFreeze = build()
  }
}
