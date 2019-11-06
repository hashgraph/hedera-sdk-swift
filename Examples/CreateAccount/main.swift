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

let newAccountKey = Ed25519PrivateKey()
print("private key for new account: \(newAccountKey)")

let receipt = try! AccountCreateTransaction(client: client)
    .setInitialBalance(0)
    .setKey(newAccountKey.publicKey)
    .setMemo("Create Account Example - Swift SDK")
    .build()
    .executeForReceipt()

print("Account created: \(receipt.accountId!)")
