import SwiftProtobuf
import Foundation

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
