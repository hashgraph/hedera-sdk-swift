import Hedera

let privateKey = Ed25519PrivateKey("302e020100300506032b65700422042091132178e72057a1d7528025956fe39b0b847f200ab59b2fdd367017f3087137")!
let op = Operator(id: AccountId(2), privateKey: privateKey)

let client = Client(node: AccountId("0.0.3")!, address: "0.testnet.hedera.com:50211")
    .setMaxTransactionFee(100_000_000)
    .setOperator(op)

let fileCreateTransactionId = try! FileCreateTransaction(client: client)
    .addKey(privateKey.publicKey)
    .setContents("This is a test")
    .setMemo("File Create Example - Swift SDK")
    .setMaxTransactionFee(1_000_000_000)
    .build()
    .execute()

print("File Create Example succeeded with transaction id \(fileCreateTransactionId)")
