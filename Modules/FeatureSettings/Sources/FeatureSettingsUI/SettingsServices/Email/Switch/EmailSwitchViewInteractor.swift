// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

class EmailSwitchViewInteractor: SwitchViewInteracting {

    typealias InteractionState = LoadingState<SwitchInteractionAsset>

    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    var switchTriggerRelay = PublishRelay<Bool>()

    private let service: EmailNotificationSettingsServiceAPI
    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(service: EmailNotificationSettingsServiceAPI) {
        self.service = service

        service.valueObservable
            .map { ValueCalculationState.value($0) }
            .map { .init(with: $0) }
            .catchErrorJustReturn(.loading)
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        switchTriggerRelay
            .do(onNext: { [weak self] _ in
                self?.stateRelay.accept(.loading)
            })
            .flatMap(weak: self) { (self, result) -> Observable<Void> in
                self.service
                    .emailNotifications(enabled: result)
                    .andThen(Observable.just(()))
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}

extension LoadingState where Content == SwitchInteractionAsset {

    /// Initializer that receives the interaction state and
    /// maps it to `self`
    fileprivate init(with state: ValueCalculationState<WalletSettings>) {
        switch state {
        case .calculating,
             .invalid:
            self = .loading
        case .value(let value):
            let emailVerified = value.isEmailVerified
            let emailNotifications = value.isEmailNotificationsEnabled
            self = .loaded(next: .init(isOn: emailNotifications, isEnabled: emailVerified))
        }
    }
}
