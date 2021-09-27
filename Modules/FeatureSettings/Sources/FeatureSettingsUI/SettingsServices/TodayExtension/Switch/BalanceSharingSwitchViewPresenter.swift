// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class BalanceSharingSwitchViewPresenter: SwitchViewPresenting {

    // MARK: - Types

    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView

    // MARK: - Properties

    let viewModel = SwitchViewModel.primary(accessibilityId: AccessibilityID.balanceSync)

    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()

    init(service: BalanceSharingSettingsServiceAPI) {
        interactor = BalanceSharingSwitchViewInteractor(service: service)

        viewModel.isSwitchedOnRelay
            .bindAndCatch(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)

        interactor.state
            .compactMap(\.value)
            .map(\.isEnabled)
            .bindAndCatch(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        interactor.state
            .compactMap(\.value)
            .map(\.isOn)
            .bindAndCatch(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
}
