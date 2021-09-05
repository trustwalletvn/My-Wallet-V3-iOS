// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
@testable import PlatformKit
import RxSwift
// import RxTest
import ToolKit
import XCTest

#if canImport(RxTest)
#error("Uncomment tests.")
#endif

class EthereumAccountDetailsServiceTests: XCTestCase {

//    var scheduler: TestScheduler!
//    var disposeBag: DisposeBag!
//    var bridge: EthereumWalletBridgeMock!
//    var client: BalanceClientAPIMock!
//    var subject: EthereumAccountDetailsService!
//
//    override func setUp() {
//        super.setUp()
//        client = BalanceClientAPIMock()
//        scheduler = TestScheduler(initialClock: 0)
//        disposeBag = DisposeBag()
//        bridge = EthereumWalletBridgeMock()
//        subject = EthereumAccountDetailsService(
//            with: bridge,
//            client: client,
//            scheduler: scheduler
//        )
//    }
//
//    override func tearDown() {
//        client = nil
//        scheduler = nil
//        disposeBag = nil
//        bridge = nil
//        subject = nil
//        super.tearDown()
//    }
//
//    func test_get_account_details() {
//        // Arrange
//        let account = EthereumAssetAccount(
//            walletIndex: 0,
//            accountAddress: MockEthereumWalletTestData.account,
//            name: CryptoCurrency.coin(.ethereum).defaultWalletName
//        )
//        let balanceDetails = BalanceDetailsResponse(balance: "2.0", nonce: 1)
//        client.balanceDetailsValue = .just(balanceDetails)
//        let expectedAccountDetails = EthereumAssetAccountDetails(
//            account: account,
//            balance: balanceDetails.cryptoValue,
//            nonce: balanceDetails.nonce
//        )
//
//        let sendObservable: Observable<EthereumAssetAccountDetails> = subject
//            .accountDetails()
//            .asObservable()
//
//        // Act
//        let result: TestableObserver<EthereumAssetAccountDetails> = scheduler
//            .start { sendObservable }
//
//        // Assert
//        let expectedEvents: [Recorded<Event<EthereumAssetAccountDetails>>] = Recorded.events(
//            .next(
//                202,
//                expectedAccountDetails
//            ),
//            .completed(203)
//        )
//
//        XCTAssertEqual(result.events, expectedEvents)
//    }
}
