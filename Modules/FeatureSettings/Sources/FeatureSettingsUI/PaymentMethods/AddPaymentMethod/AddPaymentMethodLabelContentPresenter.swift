// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class AddPaymentMethodLabelContentPresenter: LabelContentPresenting {

    typealias PresentationState = LabelContent.State.Presentation

    let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    let interactor: LabelContentInteracting
    private let disposeBag = DisposeBag()

    init(interactor: AddPaymentMethodLabelContentInteractor) {
        self.interactor = interactor
        Observable
            .combineLatest(
                interactor.state,
                interactor.descriptorObservable
            )
            .map { PresentationState(with: $0.0, descriptors: $0.1) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
