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

    override func mapResponse(_ response: Proto_Response) throws -> Data {
        guard case .contractGetBytecodeResponse(let response) = response.response else {
            throw HederaError(message: "query response was not of type contract bytecode")
        }

        return response.bytecode
    }
}
