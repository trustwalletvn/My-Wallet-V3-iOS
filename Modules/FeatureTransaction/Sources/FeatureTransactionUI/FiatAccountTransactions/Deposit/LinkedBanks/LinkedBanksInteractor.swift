// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

protocol LinkedBanksRouting: ViewableRouting {}

protocol LinkedBanksListener: AnyObject {
    /// Routes to the TransactonFlow with a given `FiatAccount`
    func routeToTransactionFlow(sourceAccount: LinkedBankAccount)

    /// Routes to `Add a Bank`
    func routeToAddABank()
}

final class LinkedBanksInteractor: Interactor, LinkedBanksInteractable {

    weak var router: LinkedBanksRouting?
    weak var listener: LinkedBanksListener?

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}
