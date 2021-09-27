// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

class BiometrySwitchViewInteractor: SwitchViewInteracting {

    typealias InteractionState = LoadingState<SwitchInteractionAsset>

    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    var switchTriggerRelay = PublishRelay<Bool>()

    var configurationStatus: Biometry.Status {
        provider.configurationStatus
    }

    var supportedBiometryType: Biometry.BiometryType {
        provider.supportedBiometricsType
    }

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private unowned let settingsAuthenticating: AppSettingsAuthenticating
    private let disposeBag = DisposeBag()
    private let provider: BiometryProviding

    init(
        provider: BiometryProviding,
        authenticationCoordinator: AuthenticationCoordinating,
        settingsAuthenticating: AppSettingsAuthenticating
    ) {
        self.provider = provider
        self.settingsAuthenticating = settingsAuthenticating

        Observable
            .just(settingsAuthenticating.biometryEnabled)
            .map { .loaded(next: .init(isOn: $0, isEnabled: true)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        NotificationCenter.when(.login) { [weak self] _ in
            guard let self = self else { return }
            self.refresh()
        }

        switchTriggerRelay
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                if $0 {
                    authenticationCoordinator.enableBiometrics()
                } else {
                    settingsAuthenticating.pin = nil
                    settingsAuthenticating.biometryEnabled = false
                    self.refresh()
                }
            })
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func refresh() {
        Observable
            .just(settingsAuthenticating.biometryEnabled)
            .map { .loaded(next: .init(isOn: $0, isEnabled: true)) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
