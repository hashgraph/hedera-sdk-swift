import Sodium
import Foundation

public class ContractCallLocalQuery: QueryBuilder<FunctionResult> {
    public override init(node: Node) {
        super.init(node: node)

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

    override func mapResponse(_ response: Proto_Response) -> Result<FunctionResult, HederaError> {
        guard case .contractCallLocal(let response) =  response.response else {
            return .failure(HederaError(message: "query response was not of type 'contractCallLocal'"))
        }

        return .success(FunctionResult(response.functionResult))
    }
}
