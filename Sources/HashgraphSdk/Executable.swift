import Foundation
import GRPC
import NIO
import HederaProtoServices

enum ExecutionState {
    case retry
    case finished
    case error
}

public class Executable<O: ProtobufConvertible, RequestT, ResponseT> {
    var nodeAccountIds: [AccountId] = []
    var nodes: [Node] = []
    var maxAttempts: UInt?
    var maxBackoff: TimeInterval?
    var minBackoff: TimeInterval?
    var nextNodeIndex: Int = 0

    init() {
    }

    func onExecute(_ client: Client) {
        fatalError("not implemented")
    }

    func toProtobuf() -> RequestT {
        fatalError("not implemented")
    }

    func shouldRetry(_ response: ResponseT) -> ExecutionState {
        fatalError("not implemented")
    }

    func shouldRetry(_ code: Proto_ResponseCodeEnum) -> ExecutionState {
        switch code {
        case .platformNotActive, .busy:
            return .retry
        case .ok:
            return .finished
        default:
            return .error
        }
    }

    func mapResponse(_ response: ResponseT) -> O {
        fatalError("not implemented")
    }

    func mapStatusError(_ response: ResponseT) -> Error {
        fatalError("not implemented")
    }

    func execute(_ node: Node) -> UnaryCall<RequestT, ResponseT> {
        fatalError("not implemented")
    }

    func execute(_ attempt: Int, _ eventLoop: EventLoop) -> EventLoopFuture<O> {
        let node = nodes[nextNodeIndex]

        // TODO: max attempt check
        // TODO: Node health check and delay

        return execute(node)
                .response
                .flatMap { response in
            switch self.shouldRetry(response) {
            case .retry:
                return self.execute(attempt + 1, eventLoop)
            case .error:
                return eventLoop.makeFailedFuture(self.mapStatusError(response))
            case .finished:
                return eventLoop.makeSucceededFuture(self.mapResponse(response))
            }
        }
    }

    public func execute(_ client: Client) -> EventLoopFuture<O> {
        maxAttempts = maxAttempts ?? client.maxAttempts
        maxBackoff = maxBackoff ?? client.maxBackoff
        minBackoff = minBackoff ?? client.minBackoff

        onExecute(client)

        nodeAccountIds = client.network.getNodeAccountIdsForExecute()
        nodes = nodeAccountIds.map { client.network.network[$0]! }

        return execute(1, client.network.eventLoopGroup.next())
    }
}
