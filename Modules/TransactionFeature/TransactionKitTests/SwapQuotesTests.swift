// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import RxSwift
// import RxTest
@testable import TransactionKit
import XCTest

#if canImport(RxTest)
#error("Uncomment tests.")
#endif

final class ExchangeRateTests: XCTestCase {

//    var scheduler: TestScheduler!
//    var disposeBag: DisposeBag!
//    var subject: SwapQuotesEngineMock!
//
//    override func setUp() {
//        super.setUp()
//
//        subject = .init(service: OrderQuoteRepositoryMock())
//        scheduler = TestScheduler(initialClock: 0)
//        disposeBag = DisposeBag()
//    }
//
//    override func tearDown() {
//        scheduler = nil
//        disposeBag = nil
//
//        super.tearDown()
//    }
//
//    func test_btc_bch_rate() throws {
//        let expectedRate = BigInt("34936063248847697954")
//        subject.updateAmount(BigInt(12345))
//        let rateObservable = subject
//            .getRate(direction: .internal, pair: .btc_eth)
//        let result: TestableObserver<BigInt> = scheduler
//            .start { rateObservable }
//        let expectedEvents: [Recorded<Event<BigInt>>] = Recorded.events(
//            .next(
//                200,
//                expectedRate
//            )
//        )
//        XCTAssertEqual(result.events, expectedEvents)
//    }
}
