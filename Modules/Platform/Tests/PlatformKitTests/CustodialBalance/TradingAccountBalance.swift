// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

class TradingAccountBalanceTests: XCTestCase {

    func testInitialiser() {
        let bitcoin = CustodialAccountBalance(
            currency: .crypto(.coin(.bitcoin)),
            response: .init(
                pending: "0",
                pendingDeposit: "0",
                pendingWithdrawal: "0",
                available: "0",
                withdrawable: "0"
            )
        )
        XCTAssertEqual(bitcoin.available.amount, 0, "CryptoCurrency.bitcoin available should be 0")
        let ethereum = CustodialAccountBalance(
            currency: .crypto(.coin(.ethereum)),
            response: .init(
                pending: "0",
                pendingDeposit: "0",
                pendingWithdrawal: "0",
                available: "100",
                withdrawable: "0"
            )
        )
        XCTAssertEqual(ethereum.available.amount, 100, "CryptoCurrency.ethereum available should be 100")
    }
}
