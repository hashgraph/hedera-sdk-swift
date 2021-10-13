import Foundation
import GRPC
import HederaProtoServices
import NIO

public final class TransferTransaction: Transaction {
  var hbarTransfers: [AccountId: Hbar] = [:]

  public func getHbarTransfers() -> [AccountId: Hbar] {
    hbarTransfers
  }

  public func addHbarTransfer(_ accountId: AccountId, _ amount: Hbar) throws -> Self {
    try requireNotFrozen()
    hbarTransfers[accountId] = hbarTransfers[accountId].map { $0 + amount } ?? amount
    return self
  }

  override func executeAsync(_ index: Int, save: Bool? = true) throws -> UnaryCall<
    Proto_Transaction, Proto_TransactionResponse
  > {
    nodes[circular: index].getCrypto().cryptoTransfer(try makeRequest(index, save: save))
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    var cryptoTransfer = body.cryptoTransfer
    var transfers = cryptoTransfer.transfers
    transfers.accountAmounts = hbarTransfers.map {
      var proto = Proto_AccountAmount()
      proto.accountID = $0.key.toProtobuf()
      proto.amount = Int64(bitPattern: $0.value.toProtobuf())
      return proto
    }
    cryptoTransfer.transfers = transfers
    body.cryptoTransfer = cryptoTransfer
  }
}
