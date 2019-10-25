import Hedera

func main() {
    let client = Client(node: AccountId("0.0.3")!, address: "0.testnet.hedera.com:50211")
        .setMaxTransactionFee(100_000_000)
        .setOperator(id: AccountId(2), secret: Ed25519PrivateKey("yourprivatekeyhere")!)

    let newAccountKey = Ed25519PrivateKey()
    
    let accountCreateTransactionId = AccountCreateTransaction(client: client)
        .setInitialBalance(0)
        .setKey(newAccountKey.publicKey)
        .setMemo("Create Account Example - Swift SDK")
        .build()
        // .sign()
        // .execute()
    
    print("Account Example succeeded with transaction id \(accountCreateTransactionId)")

    // tx.execute()

    // var receipt = GetTransactionReceiptQuery(client)
    //     .setTransactionId(txId)
    //     .execute()

    // print("receipt: \(receipt.accountId)")
}
