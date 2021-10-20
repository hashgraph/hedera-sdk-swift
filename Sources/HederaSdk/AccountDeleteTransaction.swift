import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class AccountDeleteTransaction: Transaction {
  var transferAccountId: AccountId?
  var deleteAccountId: AccountId?

  @discardableResult
  public func setTransferAccountId(_ accountId: AccountId) -> Self {
    transferAccountId = accountId
    return self
  }

  @discardableResult
  public func setDeleteAccountId(_ accountId: AccountId) -> Self {
    deleteAccountId = accountId
    return self
  }

  public func getTransferAccountId() -> AccountId? {
    transferAccountId
  }

  public func getDeleteAccountId() -> AccountId? {
    deleteAccountId
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setTransferAccountId(AccountId(proto.cryptoDelete.transferAccountID))
    setDeleteAccountId((AccountId(proto.cryptoDelete.deleteAccountID)))
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getCrypto().cryptoDelete
  }

  func build() -> Proto_CryptoDeleteTransactionBody {
    var body = Proto_CryptoDeleteTransactionBody()

    if let transferAccountId = transferAccountId {
      body.transferAccountID = transferAccountId.toProtobuf()
    }

    if let deleteAccountId = deleteAccountId {
      body.deleteAccountID = deleteAccountId.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.cryptoDelete = build()
  }
}
