// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RxSwift

final class TotalBalanceViewPresenter {

    // MARK: - Properties

    let titleContent = LabelContent(
        text: LocalizationConstants.Dashboard.Portfolio.totalBalance,
        font: .main(.medium, 16),
        color: .mutedText,
        accessibility: .id(Accessibility.Identifier.Dashboard.TotalBalanceCell.titleLabel)
    )

    // MARK: - Services

    let balancePresenter: AssetPriceViewPresenter
    let pieChartPresenter: AssetPieChartPresenter

    // MARK: - Setup

    init(
        coincore: CoincoreAPI,
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        let balanceInteractor = PortfolioBalanceChangeProvider(
            coincore: coincore,
            fiatCurrencyService: fiatCurrencyService
        )
        let chartInteractor = AssetPieChartInteractor(
            coincore: coincore,
            fiatCurrencyService: fiatCurrencyService
        )
        pieChartPresenter = AssetPieChartPresenter(
            edge: 88,
            interactor: chartInteractor
        )
        balancePresenter = AssetPriceViewPresenter(
            interactor: balanceInteractor,
            descriptors: .balance
        )
    }

    func refresh() {
        balancePresenter.refresh()
        pieChartPresenter.refresh()
    }
}

extension PortfolioBalanceChangeProvider: AssetPriceViewInteracting {
    public var state: Observable<DashboardAsset.State.AssetPrice.Interaction> {
        changeObservable
            .map { state in
                switch state {
                case .calculating, .invalid:
                    return .loading
                case .value(let change):
                    return .loaded(next: .init(
                        time: .hours(24),
                        fiatValue: change.balance.fiatValue!,
                        changePercentage: change.changePercentage,
                        fiatChange: change.change.fiatValue!
                    ))
                }
            }
    }

    public func refresh() {
        refreshBalance()
    }
}
