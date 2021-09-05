// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxSwift

public final class LinkedBankAccountCellPresenter {

    // MARK: - Public Properties

    let badgeImageViewModel: Driver<BadgeImageViewModel>
    let title: Driver<LabelContent>
    let description: Driver<LabelContent>
    let multiBadgeViewModel: Driver<MultiBadgeViewModel>

    // MARK: - Private Properties

    private static let multiBadgeInsets: UIEdgeInsets = .init(
        top: 0,
        left: 72,
        bottom: 0,
        right: 0
    )
    private let badgeFactory = SingleAccountBadgeFactory()

    // MARK: - Init

    public init(account: LinkedBankAccount, action: AssetAction) {
        multiBadgeViewModel = badgeFactory
            .badge(account: account, action: action)
            .map {
                .init(
                    layoutMargins: LinkedBankAccountCellPresenter.multiBadgeInsets,
                    height: 24.0,
                    badges: $0
                )
            }
            .asDriver(onErrorJustReturn: .init())

        title = .just(
            .init(
                text: account.label,
                font: .main(.semibold, 16.0),
                color: .titleText,
                alignment: .left,
                accessibility: .none
            )
        )
        description = .just(
            .init(
                text: LocalizationConstants.accountEndingIn + " \(account.accountNumber)",
                font: .main(.medium, 14.0),
                color: .descriptionText,
                alignment: .left,
                accessibility: .none
            )
        )
        badgeImageViewModel = .just(.default(
            image: .local(name: "icon-bank", bundle: .platformUIKit),
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        ))
    }
}
