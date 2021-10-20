import HederaSdk
import HederaCrypto
import Foundation
import GRPC
import NIO

let operatorId = ProcessInfo.processInfo.environment["OPERATOR_ID"]
let operatorKey = ProcessInfo.processInfo.environment["OPERATOR_KEY"]

if operatorId == nil || operatorKey == nil {
  fatalError("environment variables OPERATOR_KEY and OPERATOR_ID must be present")
}

let client = try! Client.forTestnet().wait()
        .setOperator(AccountId(operatorId!)!, PrivateKey(operatorKey!)!)

let info = try! AccountInfoQuery()
        .setAccountId(AccountId(3))
        .executeAsync(client)
        .wait()

print("balance = \(info)")