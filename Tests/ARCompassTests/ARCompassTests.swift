import XCTest
@testable import ARCompass

final class ARCompassTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ARCompass().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
