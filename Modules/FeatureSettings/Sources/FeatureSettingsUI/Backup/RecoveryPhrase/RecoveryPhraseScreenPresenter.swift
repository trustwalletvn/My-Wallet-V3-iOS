// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift

final class RecoveryPhraseScreenPresenter {

    private typealias AccessibilityId = Accessibility.Identifier.Backup.RecoveryPhrase

    // MARK: - Navigation Properties

    var trailingButton: Screen.Style.TrailingButton {
        .none
    }

    var leadingButton: Screen.Style.LeadingButton {
        .back
    }

    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationConstants.RecoveryPhraseScreen.title)
    }

    var barStyle: Screen.Style.Bar {
        .darkContent()
    }

    // MARK: - View Models

    let recoveryViewModel: RecoveryPhraseViewModel
    let nextViewModel: ButtonViewModel
    let title = LocalizationConstants.RecoveryPhraseScreen.title
    let subtitle: LabelContent
    let description: LabelContent

    // MARK: - Injected

    private let stateService: BackupRouterStateService
    private var recoveryPhraseVerifying: RecoveryPhraseVerifyingServiceAPI

    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        stateService: BackupRouterStateService,
        recoveryPhraseVerifying: RecoveryPhraseVerifyingServiceAPI,
        mnemonicAccess: MnemonicAccessAPI = resolve(),
        mnemonicComponentsProviding: MnemonicComponentsProviding = resolve()
    ) {
        self.stateService = stateService
        self.recoveryPhraseVerifying = recoveryPhraseVerifying

        recoveryViewModel = RecoveryPhraseViewModel(
            mnemonicAPI: mnemonicAccess,
            mnemonicComponentsProviding: mnemonicComponentsProviding
        )

        nextViewModel = .primary(
            with: LocalizationConstants.RecoveryPhraseScreen.next,
            accessibilityId: AccessibilityId.clipboardButton
        )

        subtitle = LabelContent(
            text: LocalizationConstants.RecoveryPhraseScreen.subtitle,
            font: .main(.semibold, 20.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.subtitleLabel)
        )

        description = LabelContent(
            text: LocalizationConstants.RecoveryPhraseScreen.description,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )

        nextViewModel.tapRelay
            .withLatestFrom(mnemonicComponentsProviding.components)
            .bind { [weak self] components in
                self?.recoveryPhraseVerifying.phraseComponents = components
                self?.recoveryPhraseVerifying.selection = components.pick(3)
                stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
    }

    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }
}
