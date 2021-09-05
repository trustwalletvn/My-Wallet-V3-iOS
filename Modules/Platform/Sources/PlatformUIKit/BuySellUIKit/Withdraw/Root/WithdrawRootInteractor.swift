// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import RIBs
import ToolKit

protocol WithdrawFlowRouting: AnyObject {
    func routeToFlowRoot()
    func routeToBankSelected(beneficiary: Beneficiary)
    func routeToCheckout(checkoutData: WithdrawalCheckoutData)
    func didTapBack()
    /// Indicates a request for the dismissal of the flow
    func closeFlow()
}

protocol WithdrawFlowListener: AnyObject {}

public final class WithdrawRootInteractor: Interactor,
    WithdrawFlowInteractable,
    WithdrawFlowListener,
    LinkedBanksSelectionListener,
    WithdrawAmountPageListener
{

    private typealias AnalyticsEvent = AnalyticsEvents.FiatWithdrawal

    weak var router: WithdrawFlowRouting?
    weak var listener: WithdrawFlowListener?

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
    }

    override public func didBecomeActive() {
        super.didBecomeActive()
        startFlow()
    }

    // MARK: - SelectLinkedBanksListener

    func bankSelected(beneficiary: Beneficiary) {
        router?.routeToBankSelected(beneficiary: beneficiary)
    }

    // MARK: - SelectLinkedBanksListener

    func enterAmountDidTapBack() {
        router?.didTapBack()
    }

    func linkedBankedDidTapBack() {
        router?.didTapBack()
    }

    // MARK: - WithdrawAmountPageListener

    func showCheckoutScreen(checkoutData: WithdrawalCheckoutData) {
        router?.routeToCheckout(checkoutData: checkoutData)
    }

    func checkoutDidTapBack() {
        router?.didTapBack()
    }

    // MARK: - Private methods

    private func startFlow() {
        analyticsRecorder.record(events: [
            AnalyticsEvents.FiatWithdrawal.formShown,
            AnalyticsEvents.New.Withdrawal.withdrawalViewed
        ])
        router?.routeToFlowRoot()
    }

    func closeFlow() {
        router?.closeFlow()
    }
}
