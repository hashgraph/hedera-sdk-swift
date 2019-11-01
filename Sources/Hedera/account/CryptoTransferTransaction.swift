public final class CryptoTransferTransaction: TransactionBuilder {
    public override init(client: Client? = nil) {
        super.init(client: client)

        var inner = Proto_CryptoTransferTransactionBody()
        inner.transfers = Proto_TransferList()

        body.cryptoTransfer = inner
    }

    @discardableResult
    public func add(sender: AccountId, amount: UInt64) -> Self {
        add(account: sender, amount: -Int64(amount))
    }

    @discardableResult
    public func add(recipient: AccountId, amount: UInt64) -> Self {
        add(account: recipient, amount: Int64(amount))
    }

    @discardableResult
    public func add(account: AccountId, amount: Int64) -> Self {
        var accountAmount = Proto_AccountAmount()
        accountAmount.accountID = account.toProto()
        accountAmount.amount = amount

        body.cryptoTransfer.transfers.accountAmounts.append(accountAmount)

        return self
    }
}
