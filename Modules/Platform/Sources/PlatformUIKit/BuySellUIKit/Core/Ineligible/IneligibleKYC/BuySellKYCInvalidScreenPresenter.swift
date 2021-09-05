// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift

final class BuySellKYCInvalidScreenPresenter {

    private typealias LocalizationId = LocalizationConstants.SimpleBuy.KYCInvalid
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.KYCInvalidScreen

    enum CellType {
        case announcement(AnnouncementCardViewModel)
        case numberedItem(BadgeNumberedItemViewModel)
        case label(LabelContent)
        case buttons([ButtonViewModel])
    }

    /// Returns the total count of cells
    var cellCount: Int {
        cellArrangement.count
    }

    let title = LocalizationId.title

    let cellArrangement: [CellType]

    let announcement: AnnouncementCardViewModel
    let contactSupportButtonViewModel: ButtonViewModel
    let badgeNumberedItemViewModels: [BadgeNumberedItemViewModel]

    private let disposeBag = DisposeBag()

    init(routerInteractor: SellRouterInteractor) {
        badgeNumberedItemViewModels = [
            .init(
                number: 1,
                title: LocalizationId.List.First.title,
                description: LocalizationId.List.First.description,
                descriptors: .dashboard(badgeAccessibilitySuffix: "1")
            ),
            .init(
                number: 2,
                title: LocalizationId.List.Second.title,
                description: LocalizationId.List.Second.description,
                descriptors: .dashboard(badgeAccessibilitySuffix: "2")
            ),
            .init(
                number: 3,
                title: LocalizationId.List.Third.title,
                description: LocalizationId.List.Third.description,
                descriptors: .dashboard(badgeAccessibilitySuffix: "3")
            )
        ]
        announcement = .init(
            badgeImage: .init(
                image: .local(name: "Icon-User", bundle: .platformUIKit),
                contentColor: .primaryButton,
                backgroundColor: .clear,
                cornerRadius: .none,
                size: .init(edge: 32.0)
            ),
            background: .init(color: .clear, imageName: "pcb_bg", bundle: .platformUIKit),
            title: LocalizationId.title,
            description: LocalizationId.subtitle,
            dismissState: .undismissible
        )

        contactSupportButtonViewModel = .secondary(
            with: LocalizationId.button,
            accessibilityId: "\(AccessibilityId.contactSupportButton)"
        )

        let content = LabelContent(
            text: LocalizationId.disclaimer,
            font: .main(.medium, 12.0),
            color: .descriptionText,
            alignment: .center,
            accessibility: .id(AccessibilityId.disclaimerLabel)
        )

        let badgedNumberedItems: [CellType] = badgeNumberedItemViewModels.map { .numberedItem($0) }

        cellArrangement = [.announcement(announcement)] +
            badgedNumberedItems +
            [.label(content)] +
            [.buttons([contactSupportButtonViewModel])]

        contactSupportButtonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { _ in
                routerInteractor.nextFromVerificationFailed()
            }
            .disposed(by: disposeBag)
    }
}
