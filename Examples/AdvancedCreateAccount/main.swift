import Hedera
import Foundation
import GRPC
import NIO

public func clientFromEnvironment(eventLoopGroup: EventLoopGroup) -> Client {
    guard let nodeId = ProcessInfo.processInfo.environment["NODE_ID"] else { fatalError("environment variable NODE_ID must be set")}
    guard let address = ProcessInfo.processInfo.environment["NODE_ADDRESS"] else { fatalError("environment variable NODE_ADDRESS must be set")}
    guard let operatorId = ProcessInfo.processInfo.environment["OPERATOR_ID"] else { fatalError("environment variable OPERATOR_ID must be set")}
    guard let operatorKey = ProcessInfo.processInfo.environment["OPERATOR_KEY"] else { fatalError("environment variable OPERATOR_KEY must be set")}

    return Client(node: AccountId(nodeId)!, address: address, eventLoopGroup: eventLoopGroup)
        .setOperator(Operator(id: AccountId(operatorId)!, privateKey: Ed25519PrivateKey(operatorKey)!))
}

// Make sure to shutdown the eventloop once we're done so we don't leak threads
let eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
defer {
    try! eventLoopGroup.syncShutdownGracefully()
}

let client = clientFromEnvironment(eventLoopGroup: eventLoopGroup)
    .setMaxTransactionFee(100_000_000)

let newAccountKey = Ed25519PrivateKey()

print("private key for new account: \(newAccountKey)")

let receipt = try! AccountCreateTransaction(client: client)
    .setInitialBalance(0)
    .setKey(newAccountKey.publicKey)
    .setMemo("Create Account Example - Swift SDK")
    .executeForReceipt()
    .get()

print("Account created: \(receipt.accountId!)")
