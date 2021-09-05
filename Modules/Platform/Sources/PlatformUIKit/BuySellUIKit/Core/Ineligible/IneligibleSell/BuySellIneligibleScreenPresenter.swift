// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxCocoa
import RxSwift

public final class BuySellIneligibleScreenPresenter {

    private typealias LocalizationId = LocalizationConstants.SimpleBuy.IneligibleScreen.Country
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.IneligibleScreen

    var titleLabelContent: Driver<LabelContent> {
        regionName
            .map { "\(LocalizationId.title) \($0)" }
            .map { LabelContent(
                text: $0,
                font: .main(.semibold, 20.0),
                color: .textFieldText,
                alignment: .center,
                accessibility: .id(AccessibilityId.title)
            )
            }
            .asDriver(onErrorJustReturn: .empty)
    }

    var subtitleLabelContent: Driver<LabelContent> {
        regionName
            .map { String(format: "\(LocalizationId.subtitle)", $0) }
            .map { LabelContent(
                text: $0,
                font: .main(.medium, 14.0),
                color: .descriptionText,
                alignment: .center,
                accessibility: .id(AccessibilityId.subtitle)
            )
            }
            .asDriver(onErrorJustReturn: .empty)
    }

    var imageViewContent: Driver<ImageViewContent> {
        Driver.just(
            ImageViewContent(
                imageResource: .local(name: "region-error-icon", bundle: .platformUIKit)
            )
        )
    }

    private var regionName: Single<String> {
        interactor
            .region
    }

    let buttonViewModel: ButtonViewModel

    private let interactor: BuySellIneligibleScreenInteractor
    private let disposeBag = DisposeBag()

    init(
        interactor: BuySellIneligibleScreenInteractor,
        router: SellRouterInteractor
    ) {
        self.interactor = interactor
        buttonViewModel = .secondary(
            with: LocalizationId.learnMore,
            accessibilityId: "\(AccessibilityId.learnMoreButton)"
        )
        buttonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { _ in
                router.nextFromIneligible()
            }
            .disposed(by: disposeBag)
    }
}
