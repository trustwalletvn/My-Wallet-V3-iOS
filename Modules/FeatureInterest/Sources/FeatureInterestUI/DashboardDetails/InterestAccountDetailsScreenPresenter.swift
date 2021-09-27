// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestDomain
import Localization
import PlatformUIKit
import RxSwift

public final class InterestAccountDetailsScreenPresenter {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.AccountDetails
    private typealias AccessibilityId = Accessibility.Identifier.Interest.Dashboard.InterestDetails

    // MARK: - Navigation Properties

    var trailingButton: Screen.Style.TrailingButton {
        .none
    }

    var leadingButton: Screen.Style.LeadingButton {
        .close
    }

    var titleView: Screen.Style.TitleView {
        .text(value: interactor.cryptoCurrency.name)
    }

    var barStyle: Screen.Style.Bar {
        .lightContent()
    }

    var sectionObservable: Observable<[DetailSectionViewModel]> {
        interactor
            .interactors
            .map { interactors -> [DetailCellPresenter] in
                interactors.enumerated().map { [unowned self] index, interactor in
                    switch interactor {
                    case .balance(let balanceCellInteractor):
                        let presenter: CurrentBalanceCellPresenter = .init(
                            interactor: balanceCellInteractor,
                            descriptionValue: { .just(LocalizationId.Cell.Balance.title) },
                            currency: .crypto(self.interactor.cryptoCurrency),
                            titleAccessibilitySuffix: "\(AccessibilityId.balanceCellTitle)",
                            descriptionAccessibilitySuffix: "\(AccessibilityId.balanceCellDescription)",
                            pendingAccessibilitySuffix: "\(AccessibilityId.balanceCellPending)",
                            descriptors: .default(
                                cryptoAccessiblitySuffix: "\(AccessibilityId.balanceCellCryptoAmount)",
                                fiatAccessiblitySuffix: "\(AccessibilityId.balanceCellFiatAmount)"
                            )
                        )
                        return .currentBalance(presenter)
                    case .item(let line):
                        switch line {
                        case .default(let interactor):
                            return .lineItem(
                                .default(
                                    .init(
                                        interactor: interactor,
                                        accessibilityIdPrefix: "\(AccessibilityId.lineItem).\(index)",
                                        identifier: "\(index)"
                                    )
                                )
                            )
                        }
                    }
                }
            }
            .map { $0 + [.footer(self.footerPresenter)] }
            .map { $0.map { presenter in DetailCellViewModel(presenter: presenter) } }
            .map { [DetailSectionViewModel(identifier: "", items: $0)] }
    }

    private let interactor: InterestAccountDetailsScreenInteractor
    private let footerPresenter: FooterTableViewCellPresenter

    public init(interactor: InterestAccountDetailsScreenInteractor) {
        self.interactor = interactor
        footerPresenter = .init(
            text: String(
                format: LocalizationId.Cell.Footer.title,
                interactor.cryptoCurrency.code
            ),
            accessibility: .id(AccessibilityId.footerCellTitle)
        )
    }
}
