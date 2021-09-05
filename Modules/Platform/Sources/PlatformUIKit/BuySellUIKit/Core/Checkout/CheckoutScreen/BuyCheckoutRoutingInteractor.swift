// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxRelay
import RxSwift
import ToolKit

public class BuyCheckoutRoutingInteractor: CheckoutRoutingInteracting {

    typealias StateService = ConfirmCheckoutServiceAPI &
        TransferDetailsServiceAPI &
        CancelTransferServiceAPI

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy

    private lazy var setup: Void = {
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: stateService.previousRelay)
            .disposed(by: disposeBag)

        actionRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self, action) in
                self.handle(action: action)
            }
            .disposed(by: disposeBag)
    }()

    public let actionRelay = PublishRelay<CheckoutDataAction>()
    public let previousRelay = PublishRelay<Void>()

    public let analyticsRecorder: AnalyticsEventRecorderAPI

    private unowned let stateService: StateService
    private let disposeBag = DisposeBag()

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        stateService: StateService
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        _ = setup
    }

    private func handle(action: CheckoutDataAction) {
        switch action {
        case .bankTransferDetails(let data):
            stateService.bankTransferDetails(with: data)
        case .cancel(let data):
            stateService.cancelTransfer(with: data)
            if data.isPendingDepositBankWire {
                handle(analyticsEvent: AnalyticsEvent.sbPendingModalCancelClick)
            } else {
                handle(analyticsEvent: AnalyticsEvent.sbCheckoutCancel)
            }
        case .confirm(let data, isOrderNew: let value):
            stateService.confirmCheckout(with: data, isOrderNew: value)
            handle(analyticsEvent: AnalyticsEvent.sbCheckoutConfirm(paymentMethod: data.order.paymentMethod.analyticsParameter))
        }
    }

    private func handle(analyticsEvent: AnalyticsEvent) {
        analyticsRecorder.record(event: analyticsEvent)
    }
}
