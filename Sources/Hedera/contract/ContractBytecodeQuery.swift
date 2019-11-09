import SwiftProtobuf
import Foundation
import Sodium

public class ContractBytecodeQuery: QueryBuilder<Data> {
    public override init(client: Client) {
        super.init(client: client)

        body.contractGetBytecode = Proto_ContractGetBytecodeQuery()
    }

    public func setContract(_ id: ContractId) -> Self {
        body.contractGetBytecode.contractID = id.toProto()

        return self
    }

    override func mapResponse(_ response: Proto_Response) -> Result<Data, HederaError> {
        guard case .contractGetBytecodeResponse(let response) = response.response else {
            return .failure(HederaError(message: "query response was not of type contract bytecode"))
        }

        return .success(response.bytecode)
    }
}
