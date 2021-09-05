// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A presenter for buy intro screen.
final class BuyIntroScreenPresenter {

    // MARK: - Types

    typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.IntroScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.IntroScreen

    // MARK: - Properties

    /// The screen title
    let title = LocalizedString.title

    let cardViewModel: AnnouncementCardViewModel
    let themeBackgroundImageViewContent: ImageViewContent
    let continueButtonViewModel: ButtonViewModel
    let skipButtonViewModel: ButtonViewModel

    private let disposeBag = DisposeBag()

    // MARK: - Injected

    private unowned let stateService: StateServiceAPI

    // MARK: - Setup

    init(
        stateService: StateServiceAPI,
        analytics: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.stateService = stateService

        themeBackgroundImageViewContent = .init(
            imageResource: .local(name: "sb-intro-bg-theme", bundle: .platformUIKit),
            accessibility: .id(AccessibilityId.themeBackgroundImageView)
        )

        // Card setup

        continueButtonViewModel = ButtonViewModel.primary(
            with: LocalizedString.continueButton
        )

        skipButtonViewModel = ButtonViewModel.secondary(
            with: LocalizedString.skipButton
        )

        cardViewModel = AnnouncementCardViewModel(
            badgeImage: .init(
                image: .local(name: "card-icon-cart", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(48)
            ),
            contentAlignment: .center,
            border: .none,
            title: LocalizedString.BuyCard.title,
            description: LocalizedString.BuyCard.description,
            dismissState: .undismissible
        )

        continueButtonViewModel.tapRelay
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)

        continueButtonViewModel.tapRelay
            .map { AnalyticsEvent.sbWantToBuyButtonClicked }
            .subscribe(onNext: analytics.record(event:))
            .disposed(by: disposeBag)

        skipButtonViewModel.tapRelay
            .bindAndCatch(to: stateService.previousRelay)
            .disposed(by: disposeBag)

        skipButtonViewModel.tapRelay
            .map { AnalyticsEvent.sbWantToBuyButtonSkip }
            .subscribe(onNext: analytics.record(event:))
            .disposed(by: disposeBag)

        analytics.record(event: AnalyticsEvent.sbWantToBuyScreenShown)
    }

    // MARK: - Exposed

    func previous() {
        stateService.previousRelay.accept(())
    }
}
