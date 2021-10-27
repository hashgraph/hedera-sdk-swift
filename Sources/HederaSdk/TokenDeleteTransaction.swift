import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class TokenDeleteTransaction: Transaction {
  var tokenId: TokenId?

  @discardableResult
  public func setTokenId(_ token: TokenId) -> Self {
    tokenId = token
    return self
  }

  public func getTokenId() -> TokenId? {
    tokenId
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setTokenId(TokenId(proto.tokenDeletion.token))
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getToken().deleteToken
  }

  func build() -> Proto_TokenDeleteTransactionBody {
    var body = Proto_TokenDeleteTransactionBody()

    if let tokenId = tokenId {
      body.token = tokenId.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.tokenDeletion = build()
  }
}
