// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCUI
import Localization
import PlatformUIKit
import RIBs
import RxRelay
import RxSwift

final class ReceiveKYCPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Transaction.Receive

    // MARK: - DetailsScreenPresenterAPI

    let cells: [DetailsScreen.CellType]
    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)
    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .hidden
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default
    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default
    let reloadRelay: PublishRelay<Void> = .init()
    let buttons: [ButtonViewModel]
    let extendSafeAreaUnderNavigationBar: Bool = true

    // MARK: - Private Properties

    private let headers: [Int: HeaderBuilder]
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init() {
        let model = AccountPickerHeaderModel(
            title: LocalizedString.KYC.title,
            subtitle: LocalizedString.KYC.subtitle,
            imageContent: .init(
                imageResource: ImageAsset.iconVerified.imageResource,
                accessibility: .none,
                renderingMode: .normal
            ),
            tableTitle: nil
        )
        headers = [
            0: AccountPickerHeaderBuilder(headerType: .default(model))
        ]
        let one = BadgeNumberedItemViewModel(
            number: 1,
            title: LocalizedString.KYC.card1Title,
            description: LocalizedString.KYC.card1Subtitle,
            descriptors: .dashboard(badgeAccessibilitySuffix: "receive.")
        )
        let two = BadgeNumberedItemViewModel(
            number: 2,
            title: LocalizedString.KYC.card2Title,
            description: LocalizedString.KYC.card2Subtitle,
            descriptors: .dashboard(badgeAccessibilitySuffix: "receive.")
        )
        let three = BadgeNumberedItemViewModel(
            number: 3,
            title: LocalizedString.KYC.card3Title,
            description: LocalizedString.KYC.card3Subtitle,
            descriptors: .dashboard(badgeAccessibilitySuffix: "receive.")
        )
        cells = [
            .numbered(one),
            .numbered(two),
            .numbered(three)
        ]

        let verifyNowButton = ButtonViewModel.primary(with: LocalizedString.KYC.verifyNow)
        buttons = [
            verifyNowButton
        ]
        verifyNowButton
            .tap
            .emit { _ in
                let kycRouter: KYCRouterAPI = resolve()
                kycRouter.start(parentFlow: .receive)
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Internal Methods

    func header(for section: Int) -> HeaderBuilder? {
        headers[section]
    }
}
