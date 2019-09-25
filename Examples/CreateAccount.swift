import Hedera

func main() {
    // var client = Client({
    //     AccountId("0.0.3"): "0.testnet.hedera.com:50211",
    //     // Can include more nodes here
    // })

    // client.setMaxTransactionFee(100_000_000)

    // client.setMaxQueryPayment(100_000_000)

    // client.setOperator(
    //     AccountId(account: 2),
    //     Ed25519PrivateKey("302e020100300506032b65700422042091132178e72057a1d7528025956fe39b0b847f200ab59b2fdd367017f3087137"))

    var tx = CryptoTransferTransaction()
        .setMemo("This is Da Memo")
        .add(sender: AccountId(2), amount: 10)
        .build()

    // var tx: Transaction = txBuilder.build()
    // var txId: TransactionId = tx.id

    // tx.execute()

    // var receipt = GetTransactionReceiptQuery(client)
    //     .setTransactionId(txId)
    //     .execute()

    // print("receipt: \(receipt.accountId)")
}
