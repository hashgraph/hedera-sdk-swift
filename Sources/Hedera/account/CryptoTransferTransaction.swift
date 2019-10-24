import SwiftProtobuf

public class CryptoTransferTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        var inner = Proto_CryptoTransferTransactionBody()
        inner.transfers = Proto_TransferList()

        body.cryptoTransfer = inner
    }

    public func add(sender: AccountId, amount: UInt64) -> Self {
        add(account: sender, amount: -Int64(amount))
    }

    public func add(recipient: AccountId, amount: UInt64) -> Self {
        add(account: recipient, amount: Int64(amount))
    }

    public func add(account: AccountId, amount: Int64) -> Self {
        var accountAmount = Proto_AccountAmount()
        accountAmount.accountID = account.toProto()
        accountAmount.amount = amount

        body.cryptoTransfer.transfers.accountAmounts.append(accountAmount)

        return self
    }
    
    override func executeClosure(_ client: inout Client, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try client.cryptoService(for: client.pickNode()).createAccount(tx)
    }
}
