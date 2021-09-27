// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20Kit
@testable import ERC20KitMock
import PlatformKit
@testable import PlatformKitMock
import RxSwift
import RxTest
import XCTest

class ERC20AccountDetailsServiceAPITests: XCTestCase {

    private var scheduler: TestScheduler!
    private var subject: ERC20AccountDetailsService!

    private let currency: CryptoCurrency = .erc20(.mock(name: "ERC20 1", sortIndex: 0))

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        let bridge = ERC20EthereumWalletBridgeMock(cryptoCurrency: currency)
        let service = ERC20BalanceServiceMock(cryptoCurrency: currency)
        subject = ERC20AccountDetailsService(with: bridge, service: service)
    }

    override func tearDown() {
        scheduler = nil
        subject = nil

        super.tearDown()
    }

    func test_fetch_asset_account_details() {
        // Arrange
        let accountDetailsObservable = subject
            .accountDetails(cryptoCurrency: currency)
            .asObservable()

        // Act
        let result: TestableObserver<ERC20AssetAccountDetails> = scheduler
            .start { accountDetailsObservable }

        // Assert
        let expectedEvents: [Recorded<Event<ERC20AssetAccountDetails>>] = Recorded.events(
            .next(
                200,
                ERC20AssetAccountDetails(
                    account: ERC20AssetAccount(
                        accountAddress: "0x0000000000000000000000000000000000000000",
                        name: "My \(currency.name) Wallet"
                    ),
                    balance: .create(major: 2, currency: currency)
                )
            ),
            .completed(200)
        )

        XCTAssertEqual(result.events, expectedEvents)
    }
}
