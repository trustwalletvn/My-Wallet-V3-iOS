// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import SwiftUI
import ToolKit

final class SimpleBuyPendingTransactionAnnouncement: PersistentAnnouncement & ActionableAnnouncement {

    struct Order {
        let isBankWire: Bool
        let currencyCode: String
        let isPendingDeposit: Bool
    }

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.AnnouncementCards.SimpleBuyPendingTransaction

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

        let assetCode = order?.currencyCode ?? ""

        let imageName: String
        let title: String
        let description: String
        if order?.isBankWire == true {
            title = "\(LocalizedString.titlePrefix) \(assetCode) \(LocalizedString.titleSuffix)"
            description = "\(LocalizedString.descriptionPrefix) \(assetCode) \(LocalizedString.descriptionSuffix)"
            imageName = "clock-error-icon"
        } else {
            title = ""
            description = ""
            imageName = "icon-card"
        }

        return AnnouncementCardViewModel(
            type: type,
            badgeImage: .init(
                image: .local(name: imageName, bundle: .platformUIKit),
                contentColor: .iconWarning,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .edge(32)
            ),
            title: title,
            description: description,
            buttons: [button],
            dismissState: .undismissible,
            didAppear: { [weak self] in
                guard let self = self else { return }
                self.analyticsRecorder.record(event: self.didAppearAnalyticsEvent)
            }
        )
    }

    var shouldShow: Bool {
        guard let order = order else {
            return false
        }
        // Shows only for bank wire - we need copy for card orders
        return order.isBankWire && order.isPendingDeposit
    }

    let type = AnnouncementType.simpleBuyPendingTransaction
    let analyticsRecorder: AnalyticsEventRecorderAPI

    let action: CardAnnouncementAction

    private let order: Order?

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        order: Order?,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        action: @escaping CardAnnouncementAction
    ) {
        self.order = order
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }

    init(
        orderDetails: OrderDetails?,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = CrashlyticsRecorder(),
        action: @escaping CardAnnouncementAction
    ) {
        order = orderDetails
            .flatMap { orderDetails in
                Order(
                    isBankWire: orderDetails.isBankWire,
                    currencyCode: orderDetails.outputValue.currencyType.displayCode,
                    isPendingDeposit: orderDetails.state == .pendingDeposit
                )
            }
        self.action = action
        self.analyticsRecorder = analyticsRecorder
    }
}

// MARK: SwiftUI Preview

#if DEBUG
struct SimpleBuyPendingTransactionAnnouncementContainer: UIViewRepresentable {
    typealias UIViewType = AnnouncementCardView

    func makeUIView(context: Context) -> UIViewType {
        let presenter = SimpleBuyPendingTransactionAnnouncement(
            order: .init(isBankWire: true, currencyCode: "BTC", isPendingDeposit: true),
            action: {}
        )
        return AnnouncementCardView(using: presenter.viewModel)
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

struct SimpleBuyPendingTransactionAnnouncementContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleBuyPendingTransactionAnnouncementContainer().colorScheme(.light)
        }.previewLayout(.fixed(width: 375, height: 250))
    }
}
#endif
