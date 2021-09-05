// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxRelay
import RxSwift
import ToolKit

public final class SellCheckoutRoutingInteractor: CheckoutRoutingInteracting {

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy

    private lazy var setup: Void = {
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: interactor.previousRelay)
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

    private unowned let interactor: SellRouterInteractor
    private let disposeBag = DisposeBag()

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        interactor: SellRouterInteractor
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.interactor = interactor
        _ = setup
    }

    private func handle(action: CheckoutDataAction) {
        switch action {
        case .bankTransferDetails:
            break
        case .cancel(let data):
            interactor.cancelSell(with: data)
            if data.isPendingDepositBankWire {
                handle(analyticsEvent: AnalyticsEvent.sbPendingModalCancelClick)
            } else {
                handle(analyticsEvent: AnalyticsEvent.sbCheckoutCancel)
            }
        case .confirm(let data, isOrderNew: let value):
            interactor.confirmCheckout(with: data, isOrderNew: value)
            handle(analyticsEvent: AnalyticsEvent.sbCheckoutConfirm(paymentMethod: data.order.paymentMethod.analyticsParameter))
        }
    }

    private func handle(analyticsEvent: AnalyticsEvent) {
        analyticsRecorder.record(event: analyticsEvent)
    }
}
