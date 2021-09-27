// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class VerifyCodeEntryInteractor {

    // MARK: - State

    enum InteractionState {
        /// Interactor is ready for code entry
        case ready

        /// User has entered a code and it is being verified
        case verifying

        /// The code has been verified
        case complete

        /// Code verification failed
        case failed
    }

    // MARK: - Public

    var triggerRelay = PublishRelay<Void>()
    var contentRelay = BehaviorRelay<String>(value: "")
    var interactionState: Observable<InteractionState> {
        interactionStateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let service: VerifyMobileSettingsServiceAPI
    private let interactionStateRelay = BehaviorRelay<InteractionState>(value: .ready)
    private let disposeBag = DisposeBag()

    init(service: VerifyMobileSettingsServiceAPI) {
        self.service = service
        triggerRelay
            .bindAndCatch(weak: self, onNext: { (self) in
                self.interactionStateRelay.accept(.verifying)
                self.submit()
            })
            .disposed(by: disposeBag)
    }

    private func submit() {
        service
            .verify(with: contentRelay.value)
            .subscribe(
                onCompleted: { [weak self] in
                    self?.interactionStateRelay.accept(.complete)
                },
                onError: { [weak self] _ in
                    self?.interactionStateRelay.accept(.failed)
                }
            )
            .disposed(by: disposeBag)
    }
}
