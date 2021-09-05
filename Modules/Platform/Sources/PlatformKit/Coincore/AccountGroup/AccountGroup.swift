// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

/// A `BlockchainAccount` that represents a collection of accounts, opposed to a single account.
public protocol AccountGroup: BlockchainAccount {
    var accounts: [SingleAccount] { get }

    func includes(account: BlockchainAccount) -> Bool

    var activityObservable: Observable<[ActivityItemEvent]> { get }
}

extension AccountGroup {
    /// An Observable stream that emits this AccountGroups accounts activity events.
    public var activityObservable: Observable<[ActivityItemEvent]> {
        Observable
            .combineLatest(
                accounts
                    .map(\.activity)
                    .map { $0.asObservable()
                        .startWith([])
                        .catchErrorJustReturn([])
                    }
            )
            .map { $0.flatMap { $0 } }
            .map { $0.unique.sorted(by: >) }
    }

    public var activity: Single<[ActivityItemEvent]> {
        Single
            .zip(accounts
                .map(\.activity)
                .map { $0.catchErrorJustReturn([]) })
            .map { $0.flatMap { $0 } }
            .map { $0.unique.sorted(by: >) }
    }

    public var currencyType: CurrencyType {
        guard let type = accounts.first?.currencyType else {
            fatalError("AccountGroup should have at least one account")
        }
        return type
    }

    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        let balances: [Single<MoneyValue>] = accounts
            .map { account in
                account
                    .fiatBalance(fiatCurrency: fiatCurrency)
            }
        return Single.zip(balances)
            .map { balances in
                try balances.reduce(MoneyValue.zero(currency: fiatCurrency), +)
            }
    }

    public func fiatBalance(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValue> {
        let balances: [Single<MoneyValue>] = accounts
            .map { account in
                account
                    .fiatBalance(fiatCurrency: fiatCurrency, at: date)
            }
        return Single.zip(balances)
            .map { balances in
                try balances.reduce(MoneyValue.zero(currency: fiatCurrency), +)
            }
    }

    public func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        let balancePairs: [Single<MoneyValuePair>] = accounts
            .map { account in
                account
                    .balancePair(fiatCurrency: fiatCurrency)
                    .catchErrorJustReturn(.zero(baseCurrency: account.currencyType, quoteCurrency: fiatCurrency.currency))
            }
        return Single.zip(balancePairs)
            .map { [currencyType] pairs -> MoneyValuePair in
                try pairs.reduce(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currency), +)
            }
    }

    public func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
        let balancePairs: [Single<MoneyValuePair>] = accounts
            .map { account in
                account
                    .balancePair(fiatCurrency: fiatCurrency, at: date)
                    .catchErrorJustReturn(.zero(baseCurrency: account.currencyType, quoteCurrency: fiatCurrency.currency))
            }
        return Single.zip(balancePairs)
            .map { [currencyType] pairs -> MoneyValuePair in
                try pairs.reduce(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currency), +)
            }
    }

    public func includes(account: BlockchainAccount) -> Bool {
        accounts.map(\.identifier).contains(account.identifier)
    }

    public var actions: Single<AvailableActions> {
        Single.zip(accounts.map(\.actions))
            .map { actions -> AvailableActions in
                actions.reduce(into: AvailableActions()) { $0.formUnion($1) }
            }
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        Single
            .just(accounts.map { $0.can(perform: action) })
            .flatMapConcatFirst()
    }
}

public enum AccountGroupError: Error {
    case noBalance
    case noReceiveAddress
}

extension PrimitiveSequence where Trait == SingleTrait, Element == [AccountGroup] {
    public func flatMapAllAccountGroup() -> Single<AccountGroup> {
        map { groups in
            AllAccountsGroup(
                accounts: groups.map(\.accounts).flatMap { $0 }
            )
        }
    }
}
