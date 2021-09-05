// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Verify identity announcement
final class VerifyIdentityAnnouncement: OneTimeAnnouncement & ActionableAnnouncement {

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.IdentityVerification.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.markRemoved()
                self.action()
                self.dismiss()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-v", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizationConstants.AnnouncementCards.IdentityVerification.title,
            description: LocalizationConstants.AnnouncementCards.IdentityVerification.description,
            buttons: [button],
            dismissState: .dismissible { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.dismissAnalyticsEvent)
                self.markRemoved()
                self.dismiss()
            },
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        guard isCompletingKyc else {
            return false
        }
        guard !isSunriverAirdropRegistered else {
            return false
        }
        return !isDismissed
    }

    let type = AnnouncementType.verifyIdentity
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let dismiss: CardAnnouncementAction
    let recorder: AnnouncementRecorder

    let action: CardAnnouncementAction

    private let isSunriverAirdropRegistered: Bool
    private let isCompletingKyc: Bool

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        isSunriverAirdropRegistered: Bool,
        isCompletingKyc: Bool,
        cacheSuite: CacheSuite = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        dismiss: @escaping CardAnnouncementAction,
        action: @escaping CardAnnouncementAction
    ) {
        recorder = AnnouncementRecorder(cache: cacheSuite, errorRecorder: errorRecorder)
        self.analyticsRecorder = analyticsRecorder
        self.dismiss = dismiss
        self.action = action
        self.isSunriverAirdropRegistered = isSunriverAirdropRegistered
        self.isCompletingKyc = isCompletingKyc
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct VerifyIdentityAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = VerifyIdentityAnnouncement(
            isSunriverAirdropRegistered: false,
            isCompletingKyc: false,
            dismiss: {},
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct VerifyIdentityAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerifyIdentityAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
