import Hedera
import Foundation

public func clientFromEnvironment() -> Client {
    guard let nodeId = ProcessInfo.processInfo.environment["NODE_ID"] else { fatalError("environment variable NODE_ID must be set")}
    guard let address = ProcessInfo.processInfo.environment["NODE_ADDRESS"] else { fatalError("environment variable NODE_ADDRESS must be set")}
    guard let operatorId = ProcessInfo.processInfo.environment["OPERATOR_ID"] else { fatalError("environment variable OPERATOR_ID must be set")}
    guard let operatorKey = ProcessInfo.processInfo.environment["OPERATOR_KEY"] else { fatalError("environment variable OPERATOR_KEY must be set")}

    return Client(node: AccountId(nodeId)!, address: address)
        .setOperator(Operator(id: AccountId(operatorId)!, privateKey: Ed25519PrivateKey(operatorKey)!))
}

let client = clientFromEnvironment()
    .setMaxTransactionFee(100_000_000)

let publicKey = Ed25519PrivateKey(ProcessInfo.processInfo.environment["OPERATOR_KEY"]!)!.publicKey

let receipt = try! FileCreateTransaction(client: client)
    .addKey(publicKey)
    .setContents("This is a test")
    .setMemo("File Create Example - Swift SDK")
    .setMaxTransactionFee(1_000_000_000)
    .build()
    .executeForReceipt()

print("File created: \(receipt.fileId!)")
