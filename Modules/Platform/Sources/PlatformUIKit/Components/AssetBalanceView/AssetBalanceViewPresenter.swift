// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AssetBalanceViewPresenter {

    typealias PresentationState = AssetBalanceViewModel.State.Presentation

    // MARK: - Exposed Properties

    var state: Observable<PresentationState> {
        _ = setup
        return stateRelay
            .observeOn(MainScheduler.instance)
    }

    var alignment: Driver<UIStackView.Alignment> {
        alignmentRelay.asDriver()
    }

    // MARK: - Injected

    private lazy var setup: Void = {
        // Map interaction state into presentation state
        //  and bind it to `stateRelay`.
        Observable
            .combineLatest(
                interactor.state.catchErrorJustReturn(.loading),
                alignmentRelay.asObservable()
            )
            .map { [descriptors] state, alignment in
                .init(
                    with: state,
                    alignment: alignment,
                    descriptors: descriptors
                )
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let interactor: AssetBalanceViewInteracting
    private let descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors

    // MARK: - Private Accessors

    private let alignmentRelay: BehaviorRelay<UIStackView.Alignment>
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        alignment: UIStackView.Alignment = .fill,
        interactor: AssetBalanceViewInteracting,
        descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors
    ) {
        self.interactor = interactor
        self.descriptors = descriptors
        alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: alignment)
    }
}
