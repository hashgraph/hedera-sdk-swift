import Sodium
import Foundation

public class ContractCallLocalQuery: QueryBuilder<FunctionResult> {
    public override init(client: Client) {
        super.init(client: client)

        body.contractCallLocal = Proto_ContractCallLocalQuery()
    }

    /// Set the contract id to call
    @discardableResult
    public func setContract(_ id: ContractId) -> Self {
        body.contractCallLocal.contractID = id.toProto()

        return self
    }

    /// Set the function and it's parameters
    ///
    /// The function and it's parameters must be encoded in the proper solidity format otherwise 
    /// an error will be thrown at runtime
    @discardableResult
    public func setFunctionParameters(_ data: Data) -> Self {
        body.contractCallLocal.functionParameters = data

        return self
    }

    override func mapResponse(_ response: Proto_Response) throws -> FunctionResult {
        guard case .contractCallLocal(let response) =  response.response else {
            throw HederaError(message: "query response was not of type 'contractCallLocal'")
        }

        let result = response.functionResult

        return FunctionResult(result)
    }
}
