import Hedera

let op = Operator(id: AccountId(2), privateKey: Ed25519PrivateKey("yourprivatekeyhere")!)

let client = Client(node: AccountId("0.0.3")!, address: "0.testnet.hedera.com:50211")
    .setMaxTransactionFee(100_000_000)
    .setOperator(op)

let newAccountKey = Ed25519PrivateKey()

let cryptoTransferTransactionId = try! CryptoTransferTransaction(client: client)
    .add(sender: AccountId("0.0.3")!, amount: 10000)
    .add(recipient: AccountId("0.0.2")!, amount: 10000)
    .setMemo("Transfer Crypto Example - Swift SDK")
    .build()
    .execute()

print("Example succeeded with transaction id \(cryptoTransferTransactionId)")
