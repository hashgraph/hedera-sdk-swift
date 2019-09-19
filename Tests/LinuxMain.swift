import XCTest
@testable import hederaTests

var tests = [XCTestCaseEntry]()
tests += hederaTests.allTests()
XCTMain(tests)
