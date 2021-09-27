// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxCombine
import RxRelay
import RxSwift
import ToolKit

public protocol PortfolioBalanceChangeProviding {
    var changeObservable: Observable<ValueCalculationState<PortfolioBalanceChange>> { get }
}

public struct PortfolioBalanceChange {
    public let balance: MoneyValue
    public let changePercentage: Double
    public let change: MoneyValue
}

public final class PortfolioBalanceChangeProvider: PortfolioBalanceChangeProviding {

    // MARK: - Exposed Properties

    public var changeObservable: Observable<ValueCalculationState<PortfolioBalanceChange>> {
        changeRelay
            .asObservable()
    }

    // MARK: - Private Properties

    private lazy var setup: Void = {
        Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                refreshRelay
            )
            .map(\.0)
            .flatMap { [coincore] fiatCurrency in
                Observable.zip(coincore.allAccounts.asObservable(), Observable.just(fiatCurrency))
            }
            .flatMapLatest(weak: self) { (self, data) in
                self.fetch(accountGroup: data.0, fiatCurrency: data.1)
                    .map { .value($0) }
                    .catchErrorJustReturn(.calculating)
                    .asObservable()
            }
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: changeRelay)
            .disposed(by: disposeBag)
    }()

    private var date24hAgo: Date {
        Date().addingTimeInterval(-24 * 60 * 60)
    }

    private func fetch(accountGroup: AccountGroup, fiatCurrency: FiatCurrency) -> Single<PortfolioBalanceChange> {
        Single.zip(
            accountGroup.fiatBalance(fiatCurrency: fiatCurrency),
            accountGroup.fiatBalance(fiatCurrency: fiatCurrency, at: date24hAgo)
        )
        .map { currentBalance, previousBalance in
            let percentage: Decimal // in range [0...1]
            let change = try currentBalance - previousBalance
            if currentBalance.isZero {
                percentage = 0
            } else {
                // `zero` shouldn't be possible but is handled in any case
                // in a way that would not throw
                if previousBalance.isZero || previousBalance.isNegative {
                    percentage = 0
                } else {
                    percentage = try change.percentage(of: previousBalance)
                }
            }
            return PortfolioBalanceChange(
                balance: currentBalance,
                changePercentage: percentage.doubleValue,
                change: change
            )
        }
    }

    private let coincore: CoincoreAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let changeRelay = BehaviorRelay<ValueCalculationState<PortfolioBalanceChange>>(value: .calculating)
    private let refreshRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        coincore: CoincoreAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.coincore = coincore
        self.fiatCurrencyService = fiatCurrencyService
        _ = setup
    }

    // MARK: - Public Functions

    public func refreshBalance() {
        refreshRelay.accept(())
    }
}
