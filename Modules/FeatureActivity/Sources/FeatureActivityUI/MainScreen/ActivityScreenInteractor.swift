// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureActivityDomain
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class ActivityScreenInteractor {

    typealias State = ValueCalculationState<[ActivityItemInteractor]>

    // MARK: - Public Properties

    var fiatCurrency: Observable<FiatCurrency> {
        serviceContainer
            .fiatCurrency
            .fiatCurrencyObservable
    }

    var selectedData: Observable<BlockchainAccount> {
        serviceContainer.selectionService.selectedData
    }

    var activityBalance: Observable<FiatValue> {
        Observable
            .combineLatest(fiatCurrency, selectedData)
            .flatMap { (fiatCurrency: FiatCurrency, account: BlockchainAccount) in
                account.fiatBalance(fiatCurrency: fiatCurrency)
                    .compactMap(\.fiatValue)
                    .catchErrorJustReturn(.zero(currency: fiatCurrency))
            }
    }

    var state: Observable<State> {
        stateRelay
            .asObservable()
    }

    var isEmpty: Observable<Bool> {
        stateRelay
            .asObservable()
            .map { value in
                switch value {
                case .invalid(let error):
                    return error == .empty
                case .value(let values):
                    return values.count == 0
                case .calculating:
                    return false
                }
            }
    }

    // MARK: - Private Properties

    private let refreshRelay: PublishRelay<Void> = .init()
    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let serviceContainer: ActivityServiceContaining
    private let disposeBag = DisposeBag()

    init(serviceContainer: ActivityServiceContaining) {
        self.serviceContainer = serviceContainer

        Observable
            .combineLatest(selectedData, refreshRelay.asObservable())
            .map(\.0)
            .flatMapLatest { account -> Observable<[ActivityItemEvent]> in
                if let group = account as? AccountGroup {
                    return group.activityObservable
                }
                return account.activity.asObservable()
            }
            .map { (items: [ActivityItemEvent]) in
                State(with: items, exchangeProviding: serviceContainer.exchangeProviding)
            }
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.empty))
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    func refresh() {
        refreshRelay.accept(())
    }
}

extension ActivityScreenInteractor.State {

    /// Initializer that receives the loading state and
    /// maps it to `self`
    fileprivate init(
        with items: [ActivityItemEvent],
        exchangeProviding: ExchangeProviding
    ) {
        let interactors: [ActivityItemInteractor] = items
            .sorted(by: >)
            .map { item in
                ActivityItemInteractor(
                    activityItemEvent: item,
                    exchangeAPI: exchangeProviding[item.amount.currencyType]
                )
            }
        self = interactors.isEmpty ? .invalid(.empty) : .value(interactors)
    }
}
