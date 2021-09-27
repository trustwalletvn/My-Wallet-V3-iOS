// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class UpdateMobileScreenInteractor {

    // MARK: - State

    enum InteractionState {
        /// Interactor is ready for mobile number entry
        case ready

        /// The user has entered a mobile number and it
        /// is being updated
        case updating

        /// Mobile number has been updated
        case complete

        /// Mobile update call failed
        case failed
    }

    // MARK: - Public

    var triggerRelay = PublishRelay<Void>()
    var contentRelay = BehaviorRelay<String>(value: "")
    var interactionState: Observable<InteractionState> {
        interactionStateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let interactionStateRelay = BehaviorRelay<InteractionState>(value: .ready)
    private let disposeBag = DisposeBag()

    init(service: UpdateMobileSettingsServiceAPI) {
        triggerRelay
            .withLatestFrom(contentRelay)
            .do(onNext: { [interactionStateRelay] _ in
                interactionStateRelay.accept(.updating)
            })
            .flatMap { mobile -> Observable<Void> in
                service
                    .update(mobileNumber: mobile)
                    .andThen(Observable.just(()))
            }
            .map { _ in .complete }
            .catchErrorJustReturn(.failed)
            .bindAndCatch(to: interactionStateRelay)
            .disposed(by: disposeBag)
    }
}
