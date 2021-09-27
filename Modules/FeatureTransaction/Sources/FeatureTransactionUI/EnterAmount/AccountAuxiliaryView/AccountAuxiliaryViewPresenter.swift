// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class AccountAuxiliaryViewPresenter {

    // MARK: - Public Properites

    let badgeImageViewModel: Driver<BadgeImageViewModel>
    let titleLabel: Driver<LabelContent>
    let subtitleLabel: Driver<LabelContent>
    let buttonEnabled: Driver<Bool>
    let tapRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let interactor: AccountAuxiliaryViewInteractor

    init(interactor: AccountAuxiliaryViewInteractor) {
        self.interactor = interactor

        tapRelay
            .asSignal()
            .emit(to: interactor.auxiliaryViewTappedRelay)
            .disposed(by: disposeBag)

        buttonEnabled = interactor
            .state
            .map(\.isEnabled)

        badgeImageViewModel = interactor
            .state
            .map(\.imageResource)
            .map {
                BadgeImageViewModel.default(
                    image: $0,
                    cornerRadius: .round,
                    accessibilityIdSuffix: "AccountAuxiliaryViewBadge"
                )
            }

        titleLabel = interactor
            .state
            .map(\.title)
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.semibold, 16.0),
                    color: .titleText,
                    alignment: .left,
                    accessibility: .id("AccountAuxiliaryViewTitle")
                )
            }

        subtitleLabel = interactor
            .state
            .map(\.subtitle)
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.medium, 14.0),
                    color: .descriptionText,
                    alignment: .left,
                    accessibility: .id("AccountAuxiliaryViewSubtitle")
                )
            }
    }
}

extension AccountAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    func makeViewController() -> UIViewController {
        let accountAuxiliaryView = AccountAuxiliaryView()
        accountAuxiliaryView.presenter = self
        let viewController = UIViewController()
        viewController.view.addSubview(accountAuxiliaryView)
        accountAuxiliaryView.constraint(edgesTo: viewController.view)
        return viewController
    }
}
