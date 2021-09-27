// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import BitcoinKit
import PlatformKit
import XCTest

class TransactionSizeCalculatorTests: XCTestCase {

    var subject: TransactionSizeCalculator!

    override func setUp() {
        super.setUp()

        subject = TransactionSizeCalculator()
    }

    override func tearDown() {
        subject = nil

        super.tearDown()
    }

    func test_should_return_the_right_transaction_size_empty_tx() {
        let size = subject.transactionBytes(inputs: 0, outputs: 0)
        XCTAssertEqual(size, BigUInt(10))
    }

    func test_should_return_the_right_transaction_size_1_in_2_out_tx() {
        let subject = TransactionSizeCalculator()
        let size = subject.transactionBytes(inputs: 1, outputs: 2)
        XCTAssertEqual(size, BigUInt(227))
    }

    func test_returns_correct_dust_threshold_for_fee() {
        let subject = TransactionSizeCalculator()
        let fee = Fee(feePerByte: BigUInt(55))
        let dustThreshold = subject.dustThreshold(for: fee)
        XCTAssertEqual(dustThreshold, BigUInt(10065))
    }
}
