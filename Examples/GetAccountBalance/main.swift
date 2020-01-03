import Hedera
import Foundation
import GRPC
import NIO

public func clientFromEnvironment(eventLoopGroup: EventLoopGroup) -> Client {
    let operatorId = ProcessInfo.processInfo.environment["OPERATOR_ID"]
    let operatorKey = ProcessInfo.processInfo.environment["OPERATOR_KEY"]

    if operatorId == nil || operatorKey == nil {
        fatalError("environment variables OPERATOR_KEY and OPERATOR_ID must be present")
    }

    return Client(node: AccountId(3), address: "0.testnet.hedera.com:50211", eventLoopGroup: eventLoopGroup)
        .setOperator(Operator(id: AccountId(operatorId!)!, privateKey: Ed25519PrivateKey(operatorKey!)!))
}

let eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)

defer {
    // Make sure to shutdown the eventloop once we're done so we don't leak threads
    try! eventLoopGroup.syncShutdownGracefully()
}

let client = clientFromEnvironment(eventLoopGroup: eventLoopGroup)

let balance = AccountBalanceQuery(node: client.pickNode())
    .execute(client: client)

print("balance = \(balance)")
