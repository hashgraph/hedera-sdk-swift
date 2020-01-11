import SwiftProtobuf
import Foundation
import Sodium

public struct ContractInfo {
    let contractId: ContractId
    let accountId: AccountId
    let contractAccountId: String
    let adminKey: PublicKey?
    let expirationTime: Date
    let autoRenewPeriod: TimeInterval
    let storage: UInt64
    let contractMemo: String

    init(_ contractInfo: Proto_ContractGetInfoResponse.ContractInfo) {
        contractId = ContractId(contractInfo.contractID)
        accountId = AccountId(contractInfo.accountID)
        contractAccountId = contractInfo.contractAccountID
        adminKey = PublicKey.fromProto(contractInfo.adminKey)
        expirationTime = Date(contractInfo.expirationTime)
        autoRenewPeriod = TimeInterval(contractInfo.autoRenewPeriod)!
        storage = UInt64(contractInfo.storage)
        contractMemo = contractInfo.memo
    }
}

public class ContractInfoQuery: QueryBuilder<ContractInfo> {
    public override init() {
        super.init()

        body.contractGetInfo = Proto_ContractGetInfoQuery()
    }

    public func setContractId(_ id: ContractId) -> Self {
        body.contractGetInfo.contractID = id.toProto()

        return self
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.contractGetInfo.header)
    }

    override func mapResponse(_ response: Proto_Response) -> ContractInfo {
        guard case .contractGetInfo(let response) = response.response else {
            fatalError("unreachable: response is not contractGetInfo")
        }

        return ContractInfo(response.contractInfo)
    }
}
