// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class BuyPendingOrderRoutingInteractor: PendingOrderRoutingInteracting {

    private lazy var setup: Void = {
        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: stateService.previousRelay)
            .disposed(by: disposeBag)

        tapRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self, tap) in
                self.handle(tap: tap)
            }
            .disposed(by: disposeBag)

        stateRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self, state) in
                self.handle(state: state)
            }
            .disposed(by: disposeBag)
    }()

    public let tapRelay = PublishRelay<URL>()
    public let stateRelay = PublishRelay<PendingOrderState>()
    public let previousRelay = PublishRelay<Void>()

    private unowned let stateService: StateServiceAPI
    private let disposeBag = DisposeBag()

    init(stateService: StateServiceAPI) {
        self.stateService = stateService
        _ = setup
    }

    private func handle(state: PendingOrderState) {
        switch state {
        case .pending(let orderDetails):
            stateService.orderPending(with: orderDetails)
        case .completed:
            stateService.orderCompleted()
        case .upgrade:
            stateService.promptTierUpgrade()
        }
    }

    public func handle(tap: URL) {
        stateService.show(url: tap)
    }
}
