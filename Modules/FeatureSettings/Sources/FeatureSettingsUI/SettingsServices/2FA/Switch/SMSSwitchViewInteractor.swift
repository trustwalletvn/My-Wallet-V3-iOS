// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class SMSSwitchViewInteractor: SwitchViewInteracting {

    typealias InteractionState = LoadingState<SwitchInteractionAsset>

    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    let switchTriggerRelay = PublishRelay<Bool>()

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()

    init(service: SMSTwoFactorSettingsServiceAPI & SettingsServiceAPI) {

        service.valueObservable
            .map { ValueCalculationState.value($0) }
            .map { .init(with: $0) }
            .startWith(.loading)
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        switchTriggerRelay
            .map { _ in .loading }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        switchTriggerRelay
            .flatMap {
                service
                    .smsTwoFactorAuthentication(enabled: $0)
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
            self = .loaded(next: .init(isOn: value.authenticator == .sms, isEnabled: value.isSMSVerified))
        }
    }
}
