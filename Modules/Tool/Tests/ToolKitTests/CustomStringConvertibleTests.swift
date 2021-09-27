// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ToolKit
import XCTest

final class CustomStringConvertibleTests: XCTestCase, LogDestination {

    lazy var logger: Logger = {
        let logger = Logger()
        logger.verbosity = .none
        logger.destinations = [self]
        return logger
    }()

    var message: String?

    override func setUp() {
        super.setUp()
        message = nil
    }

    func test_peek() throws {
        "hello".peek(using: logger)
        XCTAssertEqual(message, "hello")
    }

    func test_peek_with_verbosity() throws {

        let logger = Logger()
        logger.verbosity = .some
        logger.destinations = [self]

        "hello".peek(using: logger)
        XCTAssertEqual(message, "🏗 hello ← test_peek_with_verbosity()\tCustomStringConvertibleTests.swift:33")
    }

    struct Model: CustomStringConvertible {
        var value: String = "string"
        var condition: Bool = true
        var description: String { "Model(\(value), \(condition))" }
    }

    func test_peek_if_true() throws {
        Model(condition: true).peek(if: \.condition, using: logger)
        XCTAssertEqual(message, "Model(string, true)")
    }

    func test_peek_if_false() throws {
        Model(condition: false).peek(if: \.condition, using: logger)
        XCTAssertNil(message)
    }

    func test_peek_value() throws {
        Model(value: "Blockchain").peek(\.value, using: logger)
        XCTAssertEqual(message, "Blockchain")
    }

    func log(statement: String, level: LogLevel) {
        message = statement
    }
}
