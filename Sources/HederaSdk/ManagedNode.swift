import Foundation
import GRPC
import HederaProtoServices
import NIO

enum Order {
  case equal
  case less
  case greater
}

class ManagedNode {
  var address: ManagedNodeAddress
  var connection: ClientConnection?
  var lastUsed: UInt64 = 0
  var useCount: UInt32 = 0
  var backoffUntil: TimeInterval = 0
  var minBackoff: TimeAmount = TimeAmount.nanoseconds(250)
  var currentBackoff: TimeAmount = TimeAmount.nanoseconds(250)
  var attempts: UInt64 = 0

  init(_ address: ManagedNodeAddress) {
    self.address = address
  }

  func isHealthy() -> Bool {
    backoffUntil < Date().timeIntervalSince1970
  }

  func compare(_ rhs: ManagedNode) -> Order {
    if isHealthy() == rhs.isHealthy() {
      if useCount < rhs.useCount {
        return .less
      } else if useCount > rhs.useCount {
        return .greater
      } else if lastUsed < rhs.lastUsed {
        return .less
      } else if lastUsed > rhs.lastUsed {
        return .greater
      } else {
        return .equal
      }
    } else if isHealthy() && !rhs.isHealthy() {
      return .less
    } else {
      return .greater
    }
  }

  func getConnection() -> ClientConnection {
    if let connection = connection {
      return connection
    }

    let configuration = ClientConnection.Configuration.default(
      target: .hostAndPort(address.address, Int(address.port)),
      eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
    )
    connection = ClientConnection(configuration: configuration)
    return connection!
  }

  func close() -> EventLoopFuture<Void>? {
    connection?.close()
  }
}

extension ManagedNode: Comparable, Equatable {
  static func == (lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    switch lhs.compare(rhs) {
    case .equal:
      return true
    default:
      return false
    }
  }

  static func < (lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    switch lhs.compare(rhs) {
    case .less:
      return true
    default:
      return false
    }
  }

  static func <= (lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    switch lhs.compare(rhs) {
    case .less, .equal:
      return true
    default:
      return false
    }
  }

  static func >= (lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    switch lhs.compare(rhs) {
    case .greater, .equal:
      return true
    default:
      return false
    }
  }

  static func > (lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    switch lhs.compare(rhs) {
    case .greater:
      return true
    default:
      return false
    }
  }
}

extension ManagedNode: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    address.description
  }

  public var debugDescription: String {
    address.debugDescription
  }
}
