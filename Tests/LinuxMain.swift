import XCTest
@testable import HederaTests

var tests = [XCTestCaseEntry]()
tests += HederaTests.allTests()
XCTMain(tests)
