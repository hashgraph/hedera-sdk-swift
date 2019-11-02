import SwiftProtobuf
import Foundation

public final class ExchangeRateSet {
    let currentRate: ExchangeRate
    let nextRate: ExchangeRate

    init(_ proto: Proto_ExchangeRateSet) {
        currentRate = ExchangeRate(proto.currentRate)
        nextRate = ExchangeRate(proto.nextRate)
    }
}

public final class ExchangeRate {
    let hbarEquivalent: UInt32
    let centEquivalent: UInt32
    let expirationTime: Date

    init(_ proto: Proto_ExchangeRate) {
        hbarEquivalent = UInt32(proto.hbarEquiv)
        centEquivalent = UInt32(proto.centEquiv)
        expirationTime = Date(proto.expirationTime)
    }
}
