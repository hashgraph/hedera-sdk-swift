import SwiftProtobuf
import Foundation
import Sodium

public class ContractBytecodeQuery: QueryBuilder<Data> {
    public override init() {
        super.init()

        body.contractGetBytecode = Proto_ContractGetBytecodeQuery()
    }

    public func setContract(_ id: ContractId) -> Self {
        body.contractGetBytecode.contractID = id.toProto()

        return self
    }
    
    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.contractGetBytecode.header)
    }

    override func mapResponse(_ response: Proto_Response) -> Data {
        guard case .contractGetBytecodeResponse(let response) = response.response else {
            fatalError("unreachable: response is not contractGetBytecode")
        }

        return response.bytecode
    }
}
