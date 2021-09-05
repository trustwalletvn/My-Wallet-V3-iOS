// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift

final class SellIdentityIntroductionPresenter {

    private typealias LocalizationId = LocalizationConstants.SimpleBuy.IntroScreen.Sell

    enum CellType {
        case announcement(AnnouncementCardViewModel)
        case numberedItem(BadgeNumberedItemViewModel)
        case buttons([ButtonViewModel])
    }

    /// Returns the total count of cells
    var cellCount: Int {
        cellArrangement.count
    }

    // MARK: - Navigation Properties

    var trailingButton: Screen.Style.TrailingButton {
        .close
    }

    var leadingButton: Screen.Style.LeadingButton {
        .none
    }

    var titleView: Screen.Style.TitleView {
        .none
    }

    var barStyle: Screen.Style.Bar {
        .lightContent()
    }

    let cellArrangement: [CellType]

    let announcement: AnnouncementCardViewModel
    let verifyIdentityButtonViewModel: ButtonViewModel
    let badgeNumberedItemViewModels: [BadgeNumberedItemViewModel]

    private let interactor: SellRouterInteractor
    private let disposeBag = DisposeBag()

    init(interactor: SellRouterInteractor) {
        self.interactor = interactor
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
                image: .local(name: "minus-icon", bundle: .platformUIKit),
                contentColor: .white,
                backgroundColor: .primaryButton,
                cornerRadius: .round,
                size: .init(edge: 32.0)
            ),
            background: .init(color: .clear, imageName: "pcb_bg", bundle: .platformUIKit),
            border: .none,
            title: LocalizationId.title,
            description: LocalizationId.description,
            dismissState: .undismissible
        )

        verifyIdentityButtonViewModel = .primary(with: LocalizationId.verifyIdentity)

        let badgedNumberedItems: [CellType] = badgeNumberedItemViewModels.map { .numberedItem($0) }
        cellArrangement = [.announcement(announcement)] + badgedNumberedItems + [.buttons([verifyIdentityButtonViewModel])]

        verifyIdentityButtonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.interactor.nextFromIntroduction()
            }
            .disposed(by: disposeBag)
    }
}
