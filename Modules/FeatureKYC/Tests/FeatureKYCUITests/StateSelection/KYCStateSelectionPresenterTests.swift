// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
@testable import PlatformKit
@testable import PlatformKitMock
import XCTest

class KYCStateSelectionPresenterTests: XCTestCase {

    private var view: MockKYCStateSelectionView!
    private var presenter: KYCStateSelectionPresenter!

    override func setUp() {
        super.setUp()
        view = MockKYCStateSelectionView()
        let interactor = KYCStateSelectionInteractor(client: KYCClientMock())
        presenter = KYCStateSelectionPresenter(view: view, interactor: interactor)
    }

    func testSelectedSupportedKycState() {
        view.didCallContinueKycFlow = expectation(description: "Continue KYC flow when user selects valid KYC state.")
        let state = KYCState(code: "CA", countryCode: "US", name: "California", scopes: ["KYC"])
        presenter.selected(state: state)
        waitForExpectations(timeout: 0.1)
    }

    func testSelectedUnsupportedState() {
        view.didCallShowExchangeNotAvailable = expectation(
            description: "KYC flow stops when user selects unsupported state."
        )
        let state = KYCState(code: "NY", countryCode: "US", name: "New York", scopes: [])
        presenter.selected(state: state)
        waitForExpectations(timeout: 0.1)
    }
}
