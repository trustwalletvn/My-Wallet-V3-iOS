// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

final class SimpleBuyFinishSignupAnnouncement: PersistentAnnouncement & ActionableAnnouncement {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.SimpleBuyFinishSignup

    // MARK: - Properties

    var viewModel: AnnouncementCardViewModel {
        let button = ButtonViewModel.primary(
            with: LocalizedString.ctaButton
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
                image: .local(name: "card-icon-v", bundle: .main),
                contentColor: nil,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(40)
            ),
            title: LocalizedString.title,
            description: LocalizedString.description,
            buttons: [button],
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        hasIncompleteBuyFlow && canCompleteTier2
    }

    let type = AnnouncementType.simpleBuyPendingTransaction
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let action: CardAnnouncementAction

    private let hasIncompleteBuyFlow: Bool
    private let canCompleteTier2: Bool

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        canCompleteTier2: Bool,
        hasIncompleteBuyFlow: Bool,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        action: @escaping CardAnnouncementAction
    ) {
        self.canCompleteTier2 = canCompleteTier2
        self.hasIncompleteBuyFlow = hasIncompleteBuyFlow
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct SimpleBuyFinishSignupAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = SimpleBuyFinishSignupAnnouncement(
            canCompleteTier2: true,
            hasIncompleteBuyFlow: true,
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct SimpleBuyFinishSignupAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleBuyFinishSignupAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
