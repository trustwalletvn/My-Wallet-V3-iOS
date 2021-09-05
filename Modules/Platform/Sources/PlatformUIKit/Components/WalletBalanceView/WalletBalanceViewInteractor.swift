// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public final class WalletBalanceViewInteractor {

    typealias InteractionState = LoadingState<WalletBalance>

    public struct WalletBalance {

        /// The wallet's balance in fiat
        let fiatValue: FiatValue
        /// The wallet's fiat currency code
        var fiatCurrency: FiatCurrency {
            fiatValue.currencyType
        }

        public init(fiatValue: FiatValue) {
            self.fiatValue = fiatValue
        }
    }

    // MARK: - Public Properties

    var state: Observable<InteractionState> {
        _ = setup
        return stateRelay.asObservable()
    }

    // MARK: - Private Properties

    private let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    private let disposeBag = DisposeBag()
    private let stateObservableProvider: () -> Observable<InteractionState>
    private lazy var setup: Void = {
        stateObservableProvider()
            .bindAndCatch(to: self.stateRelay)
            .disposed(by: self.disposeBag)
    }()

    // MARK: - Setup

    public init(
        account: BlockchainAccount,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        stateObservableProvider = {
            fiatCurrencyService.fiatCurrencyObservable
                .flatMap { fiatCurrency in
                    account.fiatBalance(fiatCurrency: fiatCurrency)
                }
                .map { moneyValue -> InteractionState in
                    .loaded(next: WalletBalance(fiatValue: moneyValue.fiatValue!))
                }
                .startWith(.loading)
                .catchErrorJustReturn(.loading)
        }
    }
}
