import Sodium
import Foundation

public class ContractCallLocalQuery: QueryBuilder<Void> {
    public override init() {
        super.init()

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

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.contractCallLocal.header)
    }

    override func mapResponse(_ response: Proto_Response) {
        guard case .contractCallLocal(_) = response.response else {
            fatalError("unreachable: response is not contractCallLocal")
        }

        // TODO
    }
}
