// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ERC20Kit
@testable import EthereumKit
import PlatformKit
import RxSwift
// import RxTest
import XCTest

#if canImport(RxTest)
#error("Uncomment tests.")
#endif

class ERC20AccountDetailsServiceAPITests: XCTestCase {

//    var subject: ERC20AccountDetailsService!
//    var scheduler: TestScheduler!
//    var bridge: ERC20EthereumWalletBridgeMock!
//    var accountClient: ERC20AccountAPIClientMock!
//    var disposeBag: DisposeBag!
//    let pax = CryptoCurrency.erc20(.mock(name: "ERC20 1", sortIndex: 0))
//
//    override func setUp() {
//        super.setUp()
//
//        scheduler = TestScheduler(initialClock: 0)
//        disposeBag = DisposeBag()
//        bridge = ERC20EthereumWalletBridgeMock(cryptoCurrency: pax)
//        accountClient = ERC20AccountAPIClientMock(cryptoCurrency: pax)
//        subject = ERC20AccountDetailsService(
//            with: bridge,
//            service: ERC20BalanceService(with: bridge, accountClient: accountClient)
//        )
//    }
//
//    override func tearDown() {
//        scheduler = nil
//        disposeBag = nil
//        bridge = nil
//        accountClient = nil
//        subject = nil
//
//        super.tearDown()
//    }
//
//    func test_fetch_asset_account_details() {
//        // Arrange
//        let accountDetailsObservable = subject
//            .accountDetails(cryptoCurrency: pax)
//            .asObservable()
//
//        // Act
//        let result: TestableObserver<ERC20AssetAccountDetails> = scheduler
//            .start { accountDetailsObservable }
//
//        // Assert
//        let expectedEvents: [Recorded<Event<ERC20AssetAccountDetails>>] = Recorded.events(
//            .next(
//                200,
//                ERC20AssetAccountDetails(
//                    account: ERC20AssetAccount(
//                        accountAddress: "0x0000000000000000000000000000000000000000",
//                        name: "My \(pax.name) Wallet"
//                    ),
//                    balance: CryptoValue.create(major: "2.0", currency: pax)!
//                )
//            ),
//            .completed(200)
//        )
//
//        XCTAssertEqual(result.events, expectedEvents)
//    }
}
