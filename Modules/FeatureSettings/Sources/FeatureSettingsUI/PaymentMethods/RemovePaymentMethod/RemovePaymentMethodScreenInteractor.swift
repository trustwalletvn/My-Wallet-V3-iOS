// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class RemovePaymentMethodScreenInteractor {

    typealias State = ValueCalculationState<Void>

    let triggerRelay = PublishRelay<Void>()

    var state: Observable<State> {
        _ = setup
        return stateRelay.asObservable()
    }

    let data: PaymentMethodRemovalData

    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()
    private let eventRecorder: AnalyticsEventRecorderAPI

    private lazy var setup: Void = {
        stateRelay
            .filter(\.isValue)
            .take(1)
            .mapToVoid()
            .record(analyticsEvent: data.event, using: eventRecorder)
            .subscribe()
            .disposed(by: disposeBag)

        triggerRelay
            .flatMap(weak: self) { (self, _) -> Observable<State> in
                self.remove(data: self.data)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    // MARK: - Injected

    private let deletionService: PaymentMethodDeletionServiceAPI

    init(
        data: PaymentMethodRemovalData,
        deletionService: PaymentMethodDeletionServiceAPI,
        eventRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.deletionService = deletionService
        self.eventRecorder = eventRecorder
        self.data = data
    }

    private func remove(data: PaymentMethodRemovalData) -> Observable<State> {
        deletionService.delete(by: data)
            .andThen(.just(.value(())))
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.valueCouldNotBeCalculated))
    }
}
