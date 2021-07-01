import XCTest
@testable import MyLogger

final class MyLoggerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let log = MyLogger(level: LogLevel.debug, name: "test")
        
        log.debug("This is a debug message.")
        log.info("This is an info message.")
        log.warn("This is a warn message.")
        log.error("This is an error message.")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
