// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import XCTest

final class BigIntExtensionTests: XCTestCase {

    func testDivision4000by2000() {
        let divisor = BigInt(stringLiteral: "\(20000)")
        let number = BigInt(stringLiteral: "\(40000)")
        let result = number.decimalDivision(divisor: divisor)
        XCTAssertEqual(result, 2)
    }

    func testDivision9999by1111() {
        let divisor = BigInt(stringLiteral: "\(1111)")
        let number = BigInt(stringLiteral: "\(9999)")
        let result = number.decimalDivision(divisor: divisor)
        XCTAssertEqual(result, 9)
    }

    func testQuotientAndRemainder99by2() {
        let number = BigInt(stringLiteral: "\(99)")
        let divisor = BigInt(stringLiteral: "\(2)")
        let result = number.quotientAndRemainder(dividingBy: divisor)
        XCTAssertEqual(result.quotient, BigInt(49))
        XCTAssertEqual(result.remainder, BigInt(1))
    }

    func testQuotientAndRemainder120by2() {
        let number = BigInt(stringLiteral: "\(120)")
        let divisor = BigInt(stringLiteral: "\(2)")
        let result = number.quotientAndRemainder(dividingBy: divisor)
        XCTAssertEqual(result.quotient, BigInt(60))
        XCTAssertEqual(result.remainder, BigInt(0))
    }
}
