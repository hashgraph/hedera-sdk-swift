import SwiftProtobuf

struct CryptoTransferTransaction {
    private var body = Proto_CryptoTransferTransactionBody()
    private var transferList = Proto_TransferList()
 
    public mutating func add(sender: AccountId, amount: Int64) -> Self {
        addTransfer(account: sender, amount: -abs(amount))
    } 
    
    public mutating func add(recipient: AccountId, amount: Int64) -> Self {
        addTransfer(account: recipient, amount: abs(amount)) 
    }

    public mutating func addTransfer(account: AccountId, amount: Int64) -> Self {
        var accountAmount = Proto_AccountAmount()
        accountAmount.accountID = account.toProto()
        accountAmount.amount = amount
        transferList.accountAmounts.append(accountAmount)

        return self
    }
}