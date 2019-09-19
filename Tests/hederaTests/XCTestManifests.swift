import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Ed25519PrivateKeyTests.allTests),
    ]
}
#endif
