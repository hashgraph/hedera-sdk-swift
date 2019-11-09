import SwiftProtobuf
import Foundation
import Sodium

public struct ContractInfo {
    let contractId: ContractId
    let accountId: AccountId
    let contractAccountId: String
    let adminKey: Ed25519PublicKey?
    let expirationTime: Date
    let autoRenewPeriod: TimeInterval
    let storage: UInt64
    let memo: String

    init(_ contractInfo: Proto_ContractGetInfoResponse.ContractInfo) {
        contractId = ContractId(contractInfo.contractID)
        accountId = AccountId(contractInfo.accountID)
        contractAccountId = contractInfo.contractAccountID
        adminKey = Ed25519PublicKey(contractInfo.adminKey)
        expirationTime = Date(contractInfo.expirationTime)
        autoRenewPeriod = TimeInterval(contractInfo.autoRenewPeriod)!
        storage = UInt64(contractInfo.storage)
        memo = contractInfo.memo
    }
}

public class ContractInfoQuery: QueryBuilder<ContractInfo> {
    public override init(client: Client) {
        super.init(client: client)

        body.contractGetInfo = Proto_ContractGetInfoQuery()
    }

    public func setContract(_ id: ContractId) -> Self {
        body.contractGetInfo.contractID = id.toProto()

        return self
    }

    override func mapResponse(_ response: Proto_Response) -> Result<ContractInfo, HederaError> {
        guard case .contractGetInfo(let response) = response.response else {
            return .failure(HederaError(message: "query response was not of type contract info"))
        }

        return .success(ContractInfo(response.contractInfo))
    }
}
