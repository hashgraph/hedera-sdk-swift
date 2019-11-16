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

let publicKey = Ed25519PrivateKey(ProcessInfo.processInfo.environment["OPERATOR_KEY"]!)!.publicKey

let tx = FileCreateTransaction()
    .addKey(publicKey)
    .setContents("This is a test")
    .setMemo("File Create Example - Swift SDK")
    .setMaxTransactionFee(1_000_000_000)
    .build(client: client)

try! tx.execute(client: client).get()

let receipt = try! tx.queryReceipt(client: client).get()

print("File created: \(receipt.fileId!)")
