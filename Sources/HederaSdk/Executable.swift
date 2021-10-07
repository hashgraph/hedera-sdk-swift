import Foundation
import GRPC
import HederaProtoServices
import NIO

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
  var nextNodeIndex: UInt = 0

  public init() {
  }

  func onExecuteAsync(_ client: Client) {
    fatalError("not implemented")
  }

  func makeRequest() -> RequestT {
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

  func shouldRetryExceptionally(_ status: GRPCStatus) -> Bool {
    switch status.code {
    case .unauthenticated, .resourceExhausted,
      .internalError
    where status.description.range(
      of: ".*\\brst[0-9a-zA-Z]stream\\b.*", options: .regularExpression) != nil:
      return true
    default:
      return false
    }
  }

  func mapResponse(_ response: ResponseT) -> O {
    fatalError("not implemented")
  }

  func mapStatusError(_ response: ResponseT) -> Error {
    fatalError("not implemented")
  }

  func executeAsync(_ node: Node) -> UnaryCall<RequestT, ResponseT> {
    fatalError("not implemented")
  }

  func executeAsync(_ attempt: Int, _ eventLoop: EventLoop) -> EventLoopFuture<O> {
    if attempt >= maxAttempts! {
      return eventLoop.makeFailedFuture(MaxAttemptsExceededError(maxAttempts!))
    }

    let node = nodes[Int(nextNodeIndex)]

    if !node.isHealthy() {
      return eventLoop.scheduleTask(
        in: TimeAmount.milliseconds(Int64(node.getRemainingTimeForBackoff()))
      ) { () }
      .futureResult.flatMap { _ in self.executeAsync(attempt, eventLoop) }
    }

    let call = executeAsync(node)
    let responseFuture = call.response

    return call.status
      .flatMap { status in responseFuture.map { ($0, status) } }
      .flatMap { (response, status) in
        if self.shouldRetryExceptionally(status) {
          return self.executeAsync(attempt + 1, eventLoop)
        }

        switch self.shouldRetry(response) {
        case .retry:
          let delay = max(Double(self.minBackoff!), 250 * pow(2.0, (Double(attempt - 1))))

          return eventLoop.scheduleTask(in: TimeAmount.milliseconds(Int64(delay))) { () }
            .futureResult.flatMap { _ in self.executeAsync(attempt + 1, eventLoop) }
        case .error:
          return eventLoop.makeFailedFuture(self.mapStatusError(response))
        case .finished:
          return eventLoop.makeSucceededFuture(self.mapResponse(response))
        }
      }
  }

  public func executeAsync(_ client: Client) -> EventLoopFuture<O> {
    maxAttempts = maxAttempts ?? client.maxAttempts
    maxBackoff = maxBackoff ?? client.maxBackoff
    minBackoff = minBackoff ?? client.minBackoff

    onExecuteAsync(client)

    return client.network.getNodeAccountIdsForExecute().map {
      self.nodes = $0.compactMap { client.network.network[$0] }
    }.flatMap { self.executeAsync(1, client.network.eventLoopGroup.next()) }
  }
}
