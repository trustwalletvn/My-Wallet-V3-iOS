// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
@testable import BitcoinKit
import RxSwift
// import RxTest
import XCTest

#if canImport(RxTest)
#error("Uncomment tests.")
#endif

class UnspentOutputRepositoryTests: XCTestCase {

//    var scheduler: TestScheduler!
//    var disposeBag: DisposeBag!
//
//    var bridge: BitcoinWalletBridgeMock!
//    var client: APIClientMock!
//    var subject: UnspentOutputRepository!
//
//    override func setUp() {
//        super.setUp()
//
//        scheduler = TestScheduler(initialClock: 0, resolution: 0.001, simulateProcessingDelay: false)
//        disposeBag = DisposeBag()
//
//        bridge = BitcoinWalletBridgeMock()
//        client = APIClientMock()
//        subject = UnspentOutputRepository(with: bridge, client: client, scheduler: scheduler)
//    }
//
//    override func tearDown() {
//
//        scheduler = nil
//        disposeBag = nil
//
//        subject = nil
//        client = nil
//        bridge = nil
//
//        super.tearDown()
//    }
//
//    func test_fetch_unspent_outputs() {
//
//        let expectedUnspents = UnspentOutputs(outputs: [])
//
//        client.underlyingUnspentOutputs = .just(UnspentOutputsResponse(unspent_outputs: []))
//
//        // Arrange
//        let unspentOutputsObservable = subject
//            .fetchUnspentOutputs
//            .asObservable()
//
//        // Act
//        let result: TestableObserver<UnspentOutputs> = scheduler
//            .start { unspentOutputsObservable }
//
//        // Assert
//        let expectedEvents: [Recorded<Event<UnspentOutputs>>] = Recorded.events(
//            .next(
//                200,
//                expectedUnspents
//            ),
//            .completed(200)
//        )
//
//        XCTAssertEqual(result.events, expectedEvents)
//    }
}
