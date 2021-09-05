// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

/// Verify email announcement is a persistent announcement that should persist
/// as long as the user email is not verified.
final class VerifyEmailAnnouncement: PersistentAnnouncement & ActionableAnnouncement {

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizationConstants.AnnouncementCards.VerifyEmail.ctaButton
        )
        button.tapRelay
            .bind { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.actionAnalyticsEvent)
                self.action()
            }
            .disposed(by: disposeBag)

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: "card-icon-email", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizationConstants.AnnouncementCards.VerifyEmail.title,
            description: LocalizationConstants.AnnouncementCards.VerifyEmail.description,
            buttons: [button],
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        !isEmailVerified
    }

    let type = AnnouncementType.verifyEmail
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let action: CardAnnouncementAction

    private let isEmailVerified: Bool

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        isEmailVerified: Bool,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        action: @escaping CardAnnouncementAction
    ) {
        self.isEmailVerified = isEmailVerified
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct VerifyEmailAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = VerifyEmailAnnouncement(
            isEmailVerified: false,
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct VerifyEmailAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerifyEmailAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
