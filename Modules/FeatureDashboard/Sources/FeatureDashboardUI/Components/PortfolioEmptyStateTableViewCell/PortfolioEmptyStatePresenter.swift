// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class PortfolioEmptyStatePresenter {
    typealias LocalizedString = LocalizationConstants.Dashboard.Portfolio.EmptyState

    let title = LabelContent(
        text: "Welcome to Blockchain.com!",
        font: .main(.semibold, 20),
        color: .titleText,
        alignment: .center
    )
    let subtitle = LabelContent(
        text: "All your crypto balances will show up here once you buy or receive.",
        font: .main(.medium, 14),
        color: .titleText,
        alignment: .center
    )
    let cta = ButtonViewModel.primary(with: "Buy Crypto")

    private let disposeBag: DisposeBag = .init()

    init(walletOperating: WalletOperationsRouting = resolve()) {
        cta.tap
            .emit(onNext: { [walletOperating] _ in
                walletOperating.handleBuyCrypto(currency: .coin(.bitcoin))
            })
            .disposed(by: disposeBag)
    }
}
