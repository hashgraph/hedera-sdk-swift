import Hedera
import Foundation
import GRPC
import NIO

public func clientFromEnvironment(eventLoopGroup: EventLoopGroup) -> Client {
    guard let nodeId = ProcessInfo.processInfo.environment["NODE_ID"] else { fatalError("environment variable NODE_ID must be set")}
    guard let address = ProcessInfo.processInfo.environment["NODE_ADDRESS"] else { fatalError("environment variable NODE_ADDRESS must be set")}
    guard let operatorId = ProcessInfo.processInfo.environment["OPERATOR_ID"] else { fatalError("environment variable OPERATOR_ID must be set")}
    guard let operatorKey = ProcessInfo.processInfo.environment["OPERATOR_KEY"] else { fatalError("environment variable OPERATOR_KEY must be set")}

    return Client(network: [address: AccountId(nodeId)!], eventLoopGroup: eventLoopGroup)
        .setOperator(id: AccountId(operatorId)!, privateKey: Ed25519PrivateKey(operatorKey)!)
}

// Make sure to shutdown the eventloop once we're done so we don't leak threads
let eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
defer {
    try! eventLoopGroup.syncShutdownGracefully()
}

let client = clientFromEnvironment(eventLoopGroup: eventLoopGroup)
    .setMaxTransactionFee(100_000_000)

let newAccountKey = Ed25519PrivateKey.generate()!

print("private key for new account: \(newAccountKey)")

let tx = AccountCreateTransaction()
    .setInitialBalance(0)
    .setKey(newAccountKey.publicKey)
    .setTransactionMemo("Create Account Example - Swift SDK")
    .build(client: client)

let transactionId = try! tx.execute(client: client).wait()

let receipt = try! transactionId.getReceipt(client: client).wait()

print("Account created: \(receipt.accountId)")
