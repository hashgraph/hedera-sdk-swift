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

let transactionId = try! client.transferCryptoTo(recipient: AccountId("0.0.2")!, amount: 10000).get()

print("Crypto transferred successfully")
