class NodeAddress {
    var address: String
    var port: UInt16?
    var transportSecurity: Bool = false

    init(_ string: String) {
        if string.range(of: "^.*:\\d+$", options: .regularExpression) != nil {
            let parts = string.split(separator: ":", maxSplits: 2)

            address = String(parts[0])
            port = UInt16(parts[1])

            switch port {
            case .some(600), .some(50211):
                transportSecurity = false
                break
            case .some(433), .some(50212):
                transportSecurity = true
                break
            case .some(_), .none:
                break
            }
        } else {
            address = string
        }
    }
}

extension NodeAddress: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        var s = address

        if let port = port {
            s += ":"

            switch port {
            case 50211, 50212:
                s += transportSecurity ? "50212" : "50211"
                break
            case 433, 5600:
                s += transportSecurity ? "433" : "5600"
                break
            default:
                s += String(port)
            }
        }

        return s
    }

    public var debugDescription: String {
        description
    }
}
