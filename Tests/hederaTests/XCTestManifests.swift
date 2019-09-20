import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Ed25519PrivateKeyTests.allTests),
        testCase(Ed25519PublicKeyTests.allTests),
        testCase(UtilsTests.allTests),
    ]
}
#endif
