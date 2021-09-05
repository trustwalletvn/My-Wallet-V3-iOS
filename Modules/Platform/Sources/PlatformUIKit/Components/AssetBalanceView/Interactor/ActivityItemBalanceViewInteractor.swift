// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public final class ActivityItemBalanceViewInteractor: AssetBalanceViewInteracting {

    public typealias InteractionState = AssetBalanceViewModel.State.Interaction

    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(activityItemBalanceFetching: ActivityItemBalanceFetching) {
        activityItemBalanceFetching
            .calculationState
            .map { state -> InteractionState in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let result):
                    return .loaded(
                        next: .init(
                            fiatValue: result.quote,
                            cryptoValue: result.base,
                            pendingValue: .zero(currency: result.base.currency)
                        )
                    )
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    public func refresh() {}
}
