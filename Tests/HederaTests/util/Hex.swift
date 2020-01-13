import Foundation

extension Data {
    func hex() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
