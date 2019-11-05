import Hedera

let op = Operator(id: AccountId(2), privateKey: Ed25519PrivateKey("yourprivatekeyhere")!)

let client = Client(node: AccountId("0.0.3")!, address: "0.testnet.hedera.com:50211")
    .setMaxTransactionFee(100_000_000)
    .setOperator(op)
    .setMaxQueryPayment(1_000_000_000)

let fileInfo = try! FileInfoQuery(client: client)
    .setFile(FileId(119300))
    .execute()

print("FileInfo Example succeeded with result \(fileInfo)")
