// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxRelay
import RxSwift
import ToolKit

public final class BuyTransferCancellationRoutingInteractor: TransferOrderRoutingInteracting {

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy

    private lazy var setup: Void = {
        nextRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)

        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.analyticsRecorder.record(event: AnalyticsEvent.sbCancelOrderGoBack)
                self.stateService.previousRelay.accept(())
            }
            .disposed(by: disposeBag)
    }()

    public let nextRelay = PublishRelay<Void>()
    public let previousRelay = PublishRelay<Void>()
    public let analyticsRecorder: AnalyticsEventRecorderAPI

    private let disposeBag = DisposeBag()
    private unowned let stateService: StateServiceAPI

    public init(
        stateService: StateServiceAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        _ = setup
    }
}
