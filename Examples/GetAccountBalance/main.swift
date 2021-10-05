import HederaSdk
import HederaCrypto
import Foundation
import GRPC
import NIO

//let operatorId = ProcessInfo.processInfo.environment["OPERATOR_ID"]
//let operatorKey = ProcessInfo.processInfo.environment["OPERATOR_KEY"]
//
//if operatorId == nil || operatorKey == nil {
//    fatalError("environment variables OPERATOR_KEY and OPERATOR_ID must be present")
//}

let client = Client.forNetwork(["0.testnet.hedera.com:50211": AccountId(3)])
//        .setOperator(AccountId(operatorId!)!, PrivateKey(operatorKey!)!)

let balance = try! AccountBalanceQuery()
        .setAccountId(AccountId(3))
        .executeAsync(client)
        .wait()

print("balance = \(balance)")