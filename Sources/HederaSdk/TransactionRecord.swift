import Foundation
import HederaProtoServices

public final class TransactionRecord {
  public let receipt: TransactionReceipt?
  public let transactionHash: Data
  public let consensusTimestamp: Date?
  public let transactionId: TransactionId?
  public let transactionFee: Hbar
  public let transfers: [Transfer]?
  public let tokenTransfer: [TokenId: [TokenTransfer]]
  public let nftTransfers: [TokenId: [TokenNftTransfer]]
  public let callResult: ContractFunctionResult

  init(
    _ receipt: TransactionReceipt?, _ transactionHash: Data, _ consensusTimestamp: Date?,
    _ transactionId: TransactionId?, _ transactionFee: Hbar, _ transfers: [Transfer]?,
    _ tokenTransfer: [TokenId: [TokenTransfer]], _ nftTransfers: [TokenId: [TokenNftTransfer]],
    _ callResult: ContractFunctionResult
  ) {
    self.receipt = receipt
    self.transactionHash = transactionHash
    self.consensusTimestamp = consensusTimestamp
    self.transactionId = transactionId
    self.transactionFee = transactionFee
    self.transfers = transfers
    self.tokenTransfer = tokenTransfer
    self.nftTransfers = nftTransfers
    self.callResult = callResult
  }
}

extension TransactionRecord: ProtobufConvertible {
  convenience init?(_ proto: Proto_TransactionRecord) {
    self.init(
      proto.hasReceipt ? TransactionReceipt(proto.receipt) : nil,
      proto.transactionHash,
      proto.hasConsensusTimestamp ? Date(proto.consensusTimestamp) : nil,
      proto.hasTransactionID ? TransactionId(proto.transactionID) : nil,
      Hbar(proto.transactionFee),
      proto.hasTransferList ? proto.transferList.accountAmounts.map { Transfer($0)! } : nil,
      proto.tokenTransferLists.reduce(into: [TokenId: [TokenTransfer]]()) {
        $0[TokenId($1.token)] = $1.transfers.map { TokenTransfer($0)! }
      },
      proto.tokenTransferLists.reduce(into: [TokenId: [TokenNftTransfer]]()) {
        $0[TokenId($1.token)] = $1.nftTransfers.map { TokenNftTransfer($0)! }
      },
      ContractFunctionResult(proto.contractCallResult)!
    )
  }

  func toProtobuf() -> Proto_TransactionRecord {
    var proto = Proto_TransactionRecord()
    proto.transactionHash = transactionHash
    proto.transactionFee = UInt64(transactionFee.toProtobuf())
    proto.contractCallResult = callResult.toProtobuf()
    proto.tokenTransferLists = tokenTransfer.map {
      var prot = Proto_TokenTransferList()
      prot.token = $0.key.toProtobuf()
      prot.transfers = $0.value.map {
        $0.toProtobuf()
      }
      return prot
    }
    proto.tokenTransferLists.append(
      contentsOf: nftTransfers.map {
        var prot = Proto_TokenTransferList()
        prot.token = $0.key.toProtobuf()
        prot.nftTransfers = $0.value.map {
          $0.toProtobuf()
        }
        return prot
      })

    if let transfers = transfers {
      proto.transferList.accountAmounts = transfers.map {
        $0.toProtobuf()
      }
    }

    if let receipt = receipt {
      proto.receipt = receipt.toProtobuf()
    }

    if let consensusTimestamp = consensusTimestamp {
      proto.consensusTimestamp = consensusTimestamp.toProtobuf()
    }

    if let transactionId = transactionId {
      proto.transactionID = transactionId.toProtobuf()
    }

    return proto
  }
}
