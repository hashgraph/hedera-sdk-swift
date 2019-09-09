import XCTest
import hederaTests

var tests = [XCTestCaseEntry]()
tests += hederaTests.allTests()
XCTMain(tests)
