import Foundation
import GRPC
import NIO

let DEFAULT_MIN_BACKOFF: TimeInterval = TimeInterval(250)
let DEFAULT_MAX_BACKOFF: TimeInterval = TimeInterval(8000)

// https://stackoverflow.com/questions/31443645/simplest-way-to-throw-an-error-exception-with-a-custom-message-in-swift
extension String: LocalizedError {
  public var errorDescription: String? { self }
}

class ManagedNetwork<ManagedNodeT: ManagedNode<KeyT>, KeyT: Hashable, SdkNetworkT: Sequence> {
  var network: [KeyT: ManagedNodeT] = [:]
  var nodes: [ManagedNodeT] = []

  var lock: DispatchSemaphore = DispatchSemaphore(value: 1)
  var eventLoopGroup: EventLoopGroup

  var minBackoff: TimeInterval = DEFAULT_MIN_BACKOFF
  var maxBackoff: TimeInterval = DEFAULT_MAX_BACKOFF

  var maxNodeAttempts: UInt32?

  var transportSecurity: Bool = false

  var networkName: NetworkName?

  init(_ eventLoopGroup: EventLoopGroup) {
    self.eventLoopGroup = eventLoopGroup
  }

  func getMinBackoff() -> TimeInterval {
    minBackoff
  }

  @discardableResult
  func setMinBackoff(_ minBackoff: TimeInterval) -> Self {
    self.minBackoff = minBackoff
    return self
  }

  func getMaxBackoff() -> TimeInterval {
    maxBackoff
  }

  @discardableResult
  func setMaxBackoff(_ maxBackoff: TimeInterval) -> Self {
    self.maxBackoff = maxBackoff
    return self
  }

  func getMaxNodeAttempts() -> UInt32? {
    maxNodeAttempts
  }

  @discardableResult
  func setMaxNodeAttempts(_ maxNodeAttempts: UInt32) -> Self {
    self.maxNodeAttempts = maxNodeAttempts
    return self
  }

  func isTransportSecurity() -> Bool {
    transportSecurity
  }

  @discardableResult
  func setTransportSecurity(_ transportSecurity: Bool) -> Self {
    self.transportSecurity = transportSecurity
    return self
  }

  func getNetworkName() -> NetworkName? {
    networkName
  }

  @discardableResult
  func setNetworkName(_ networkName: NetworkName?) -> Self {
    self.networkName = networkName
    return self
  }

  func createNodeFromNetworkEntry(_ entry: SdkNetworkT.Element) -> ManagedNodeT? {
    fatalError("not implemented")
  }

  func getNodesToRemove(_ network: SdkNetworkT) -> [Int] {
    fatalError("not implemented")
  }

  func checkNetworkContainsEntry(_ entry: SdkNetworkT.Element) -> Bool {
    fatalError("not implemented")
  }

  func setNetwork<T>(_ network: SdkNetworkT) -> EventLoopFuture<T> where T: ManagedNetwork {
    lock.wait()

    let eventLoop = eventLoopGroup.next()

    if nodes.isEmpty {
      for entry in network {
        guard let node = createNodeFromNetworkEntry(entry) else {
          return eventLoop.makeFailedFuture("failed to create network node from network entry")
        }
        self.network[node.getKey()] = node
        nodes.append(node)
      }

    }

    var futures: [EventLoopFuture<Void>?] = []

    for index in getNodesToRemove(network) {
      let node = nodes[index]
      nodes.remove(at: index)
      futures.append(node.close())
      self.network.removeValue(forKey: node.getKey())
    }

    for entry in network {
      if !checkNetworkContainsEntry(entry) {
        guard let node = createNodeFromNetworkEntry(entry) else {
          return eventLoop.makeFailedFuture("failed to create network node from network entry")
        }

        self.network[node.getKey()] = node
        nodes.append(node)
      }
    }

    lock.signal()

    return EventLoopFuture<Void>.whenAllSucceed(
      futures.compactMap { $0 },
      on: eventLoopGroup.next()
    ).map { (results: [Void]) -> Void in Void() }.map { self as! T }
  }

  func removeDeadNodes() -> EventLoopFuture<Void>? {
    var futures: [ManagedNodeT] = []

    if let maxNodeAttempts = maxNodeAttempts {
      nodes = nodes.filter {
        if $0.attempts >= maxNodeAttempts {
          network.removeValue(forKey: $0.getKey())
          futures.append($0)
          return false
        } else {
          return true
        }
      }
    }

    return EventLoopFuture<Void>.whenAllSucceed(
      futures.compactMap { $0.close() },
      on: eventLoopGroup.next()
    ).map { (results: [Void]) -> Void in Void() }
  }

  func getNumberOfMostHealthyNodes(_ count: Int) -> EventLoopFuture<ArraySlice<ManagedNodeT>> {
    nodes.sort()
    return removeDeadNodes().map { $0.map { _ in self.nodes[0..<1] } }
      ?? eventLoopGroup.next().makeSucceededFuture(nodes[0..<min(count, nodes.count)])
  }

  func close() -> EventLoopFuture<Void> {
    EventLoopFuture<Void>.whenAllSucceed(
      nodes.compactMap { $0.close() },
      on: eventLoopGroup.next()
    ).map { (results: [Void]) -> Void in Void() }
  }
}
