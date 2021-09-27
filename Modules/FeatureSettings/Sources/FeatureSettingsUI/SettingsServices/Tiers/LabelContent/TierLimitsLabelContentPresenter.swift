// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class TierLimitsLabelContentPresenter: LabelContentPresenting {

    typealias PresentationState = LabelContent.State.Presentation

    let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    let interactor: LabelContentInteracting
    private let disposeBag = DisposeBag()

    init(
        provider: TierLimitsProviding,
        descriptors: LabelContent.Value.Presentation.Content.Descriptors
    ) {
        interactor = TierLimitsLabelContentInteractor(limitsProviding: provider)
        interactor.state
            .map { PresentationState(with: $0, descriptors: descriptors) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
