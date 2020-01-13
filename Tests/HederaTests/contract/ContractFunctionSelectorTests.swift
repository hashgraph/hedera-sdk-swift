@testable import Hedera
import XCTest
import Foundation

final class ContractFunctionSelectorTests: XCTestCase {
    static let allTests = [
        ("testBuilds", testBuilds)
    ]

    func testBuilds() {
        let function = ContractFunctionSelector(nil)
            .addInt32()
            .build("f")

        let expectedOutput = "ab490272"

        XCTAssertEqual(Data((try? function.get())!).hex(), expectedOutput)
    }
}
