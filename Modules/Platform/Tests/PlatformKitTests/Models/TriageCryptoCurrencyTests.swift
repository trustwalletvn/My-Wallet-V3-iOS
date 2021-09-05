// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation
import XCTest

@testable import PlatformKit

final class TriageCryptoCurrencyTests: XCTestCase {

    func testCorrectDisplayOfSTX() {
        let amount = BigInt("\(10000000)")!
        let currency = TriageCryptoCurrency.blockstack
        let displayValue = currency.displayValue(amount: amount, locale: .US)
        XCTAssertEqual(displayValue, "1.0")
    }
}
