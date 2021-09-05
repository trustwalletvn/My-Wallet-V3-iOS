// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Wallet Intro announcement is a periodic announcement that can also be entirely removed
final class WalletIntroAnnouncement: PeriodicAnnouncement & RemovableAnnouncement & ActionableAnnouncement {

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let ctaButton = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.Welcome.ctaButton
        )
        ctaButton.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        let skipButton = ButtonViewModel.secondary(
            with: LocalizationConstants.AnnouncementCards.Welcome.skipButton
        )
        skipButton.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markDismissed()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "logo_small", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizationConstants.AnnouncementCards.Welcome.title,
            description: LocalizationConstants.AnnouncementCards.Welcome.description,
            buttons: [ctaButton, skipButton],
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: AnalyticsEvents.WalletIntro.walletIntroOffered)
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        !isDismissed
    }

    let type = AnnouncementType.walletIntro
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    let appearanceRules: PeriodicAnnouncementAppearanceRules

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        cacheSuite: CacheSuite = resolve(),
        reappearanceTimeInterval: TimeInterval,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        action: @escaping CardAnnouncementAction,
        dismiss: @escaping CardAnnouncementAction
    ) {
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        appearanceRules = PeriodicAnnouncementAppearanceRules(
            recessDurationBetweenDismissals: reappearanceTimeInterval,
            maxDismissalCount: 3
        )
        self.action = action
        self.dismiss = dismiss
        self.analyticsRecorder = analyticsRecorder
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct WalletIntroAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = WalletIntroAnnouncement(
            reappearanceTimeInterval: 0,
            action: {},
            dismiss: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct WalletIntroAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WalletIntroAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 350))
    }
}
#endif
