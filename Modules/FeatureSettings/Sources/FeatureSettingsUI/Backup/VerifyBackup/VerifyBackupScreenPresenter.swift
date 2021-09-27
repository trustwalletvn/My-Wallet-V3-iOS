// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureSettingsDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class VerifyBackupScreenPresenter {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.Backup.VerifyBackup

    // MARK: - Navigation Properties

    var trailingButton: Screen.Style.TrailingButton {
        .none
    }

    var leadingButton: Screen.Style.LeadingButton {
        .back
    }

    var titleView: Screen.Style.TitleView {
        .text(value: LocalizationConstants.VerifyBackupScreen.title)
    }

    var barStyle: Screen.Style.Bar {
        .darkContent()
    }

    // MARK: - View Models

    let verifyButtonViewModel: ButtonViewModel

    let firstTextFieldViewModel: ValidationTextFieldViewModel
    let secondTextFieldViewModel: ValidationTextFieldViewModel
    let thirdTextFieldViewModel: ValidationTextFieldViewModel

    let descriptionLabel: LabelContent
    let errorLabel: LabelContent

    // MARK: - Rx

    var errorDescriptionVisibility: Driver<Visibility> {
        errorDescriptionVisibilityRelay.asDriver()
    }

    // MARK: - Injected

    private let loadingViewPresenter: LoadingViewPresenting
    private let stateService: BackupRouterStateServiceAPI
    private let service: RecoveryPhraseVerifyingServiceAPI

    // MARK: - Accessors

    private let errorDescriptionVisibilityRelay = BehaviorRelay(value: Visibility.hidden)
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        stateService: BackupRouterStateService,
        service: RecoveryPhraseVerifyingServiceAPI,
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.stateService = stateService
        self.loadingViewPresenter = loadingViewPresenter
        self.service = service

        let subset = service.selection
        let mnemonic = service.phraseComponents

        let firstIndex = mnemonic.firstIndex(of: subset[0]) ?? 0
        let secondIndex = mnemonic.firstIndex(of: subset[1]) ?? 0
        let thirdIndex = mnemonic.firstIndex(of: subset[2]) ?? 0

        errorLabel = LabelContent(
            text: LocalizationConstants.VerifyBackupScreen.errorDescription,
            font: .main(.medium, 12.0),
            color: .destructive,
            accessibility: .id(AccessibilityId.errorLabel)
        )

        descriptionLabel = LabelContent(
            text: LocalizationConstants.VerifyBackupScreen.description,
            font: .main(.medium, 14.0),
            color: .textFieldText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )

        firstTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerification(index: firstIndex),
            validator: TextValidationFactory.Backup.word(value: subset[0]),
            accessibilitySuffix: subset[0],
            messageRecorder: resolve()
        )

        secondTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerification(index: secondIndex),
            validator: TextValidationFactory.Backup.word(value: subset[1]),
            accessibilitySuffix: subset[1],
            messageRecorder: resolve()
        )

        thirdTextFieldViewModel = ValidationTextFieldViewModel(
            with: .backupVerification(index: thirdIndex),
            validator: TextValidationFactory.Backup.word(value: subset[2]),
            accessibilitySuffix: subset[2],
            messageRecorder: resolve()
        )

        verifyButtonViewModel = .primary(
            with: LocalizationConstants.VerifyBackupScreen.action,
            accessibilityId: AccessibilityId.verifyBackupButton
        )

        let states = Observable
            .combineLatest(
                firstTextFieldViewModel.state,
                secondTextFieldViewModel.state,
                thirdTextFieldViewModel.state
            )
            .share(replay: 1)

        let isValid = states
            .map { $0.0.isValid && $0.1.isValid && $0.2.isValid }
            .share(replay: 1)

        isValid
            .bindAndCatch(to: verifyButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        let isEmpty = states
            .map { $0.0.isEmpty || $0.1.isEmpty || $0.2.isEmpty }

        Observable
            .combineLatest(isValid, isEmpty)
            .map { $0.0 || $0.1 }
            .map { $0 ? .hidden : .visible }
            .bindAndCatch(to: errorDescriptionVisibilityRelay)
            .disposed(by: disposeBag)

        verifyButtonViewModel
            .tapRelay
            .throttle(
                .milliseconds(500),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.markBackupVerified()
            }
            .disposed(by: disposeBag)
    }

    func navigationBarLeadingButtonTapped() {
        stateService.previousRelay.accept(())
    }

    private func markBackupVerified() {
        service.markBackupVerified()
            .handleLoaderForLifecycle(
                loader: loadingViewPresenter,
                style: .circle,
                text: LocalizationConstants.syncingWallet
            )
            .catchError { _ in
                // There was an error syncing wallet
                // Ignore
                .empty()
            }
            .andThen(Observable.just(()))
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)
    }
}
