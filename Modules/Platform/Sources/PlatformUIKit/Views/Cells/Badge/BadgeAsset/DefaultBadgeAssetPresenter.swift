// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public final class DefaultBadgeAssetPresenter: BadgeAssetPresenting {
    public typealias PresentationState = BadgeAsset.State.BadgeItem.Presentation

    public var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }

    public let interactor: BadgeAssetInteracting
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    public init(interactor: BadgeAssetInteracting = DefaultBadgeAssetInteractor()) {
        self.interactor = interactor
        interactor.state
            .map { .init(with: $0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
