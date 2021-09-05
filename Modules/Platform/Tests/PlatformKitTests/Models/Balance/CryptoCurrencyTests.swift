// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
@testable import PlatformKitMock
import XCTest

class CryptoCurrencyTests: XCTestCase {

    private var cryptoCurrencyDesiredOrder: [CryptoCurrency] {
        [
            .coin(.bitcoin),
            .coin(.ethereum),
            .coin(.bitcoinCash),
            .coin(.stellar),
            .coin(.mock(name: "Custodial 1", sortIndex: 5)),
            .coin(.mock(name: "Custodial 2", sortIndex: 11)),
            .coin(.mock(name: "Custodial 3", sortIndex: 12)),
            .coin(.mock(name: "Custodial 4", sortIndex: 13)),
            .erc20(.mock(name: "ERC20 1", sortIndex: 0)),
            .erc20(.mock(name: "ERC20 2", sortIndex: 1)),
            .erc20(.mock(name: "ERC20 3", sortIndex: 2)),
            .erc20(.mock(name: "ERC20 4", sortIndex: 3)),
            .erc20(.mock(name: "ERC20 5", sortIndex: 4))
        ]
    }

    func testSortedCryptoCurrencyArrayIsInCorrectOrder() {
        XCTAssertTrue(
            cryptoCurrencyDesiredOrder.shuffled().sorted() == cryptoCurrencyDesiredOrder,
            "sut.allEnabledCryptoCurrencies.sorted() is not as expected."
        )
    }
}
