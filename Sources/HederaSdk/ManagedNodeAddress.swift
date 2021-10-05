import Foundation

final class ManagedNodeAddress {
  var address: String
  var port: UInt16

  required init(_ address: String, _ port: UInt16) {
    self.address = address
    self.port = port
  }

  func toInsecure() -> ManagedNodeAddress {
    var port = port

    switch port {
    case 50212:
      port = 50211
      break
    case 433:
      port = 5600
      break
    default: break
    }

    return ManagedNodeAddress(address, port)
  }

  func toSecure() -> ManagedNodeAddress {
    var port = port

    switch port {
    case 50211:
      port = 50212
      break
    case 5600:
      port = 433
      break
    default: break
    }

    return ManagedNodeAddress(address, port)
  }

  func isTransportSecurity() -> Bool {
    port == 50212 || port == 433
  }
}

let hostAndPort = try! NSRegularExpression(
  pattern: #"^(?<address>\\S+):(?<port>\\d+)$"#,
  options: []
)

extension ManagedNodeAddress: LosslessStringConvertible {
  convenience init?(_ description: String) {
    let matches = hostAndPort.matches(
      in: description, options: [],
      range: NSRange(
        description.startIndex..<description.endIndex,
        in: description
      ))

    guard let match = matches.first else {
      return nil
    }

    if let addressRange = Range(match.range(withName: "address"), in: description),
      let portRange = Range(match.range(withName: "address"), in: description)
    {
      let address = String(description[addressRange])
      guard let port = UInt16(String(description[portRange])) else {
        return nil
      }

      self.init(address, port)
    }

    return nil
  }
}

extension ManagedNodeAddress: CustomStringConvertible {
  var description: String {
    "\(address):\(port)"
  }

  var debugDescription: String {
    description
  }
}
