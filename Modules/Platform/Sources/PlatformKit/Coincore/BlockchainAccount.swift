// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import RxSwift
import ToolKit

public typealias AvailableActions = Set<AssetAction>

public protocol TradingAccount {}

public protocol BankAccount {}

public protocol NonCustodialAccount {}

public protocol InterestAccount {}

public protocol BlockchainAccount: Account {

    /// A unique identifier for this `BlockchainAccount`.
    ///
    /// This may be used to compare if two BlockchainAccount are the same.
    var identifier: AnyHashable { get }

    /// The total balance on this account.
    var balance: Single<MoneyValue> { get }

    /// The pending balance of this account.
    var pendingBalance: Single<MoneyValue> { get }

    /// Emits `Set` containing all actions this account can execute.
    var actions: Single<AvailableActions> { get }

    var activity: Single<[ActivityItemEvent]> { get }

    /// Indicates if this account is funded.
    ///
    /// Depending of the account implementation, this may not strictly mean a positive balance.
    /// Some accounts may be set as `isFunded` if they have ever had a positive balance in the past.
    var isFunded: Single<Bool> { get }

    /// The balance of this account exchanged to the given fiat currency.
    func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue>

    /// The balance of this account exchanged to the given fiat currency.
    func fiatBalance(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValue>

    /// The balance of this account exchanged to the given fiat currency.
    func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair>

    /// The balance of this account exchanged to the given fiat currency.
    func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair>

    /// Checks if this account can execute the given action.
    func can(perform action: AssetAction) -> Single<Bool>

    /// The `ReceiveAddress` for the given account
    var receiveAddress: Single<ReceiveAddress> { get }

    /// The balance, not including uncleared and locked,
    /// that the user is able to utilize in a transaction
    var actionableBalance: Single<MoneyValue> { get }

    /// Some wallets are double encrypted and have a second password.
    var requireSecondPassword: Single<Bool> { get }
}

extension BlockchainAccount {

    public func can(perform action: AssetAction) -> AnyPublisher<Bool, Error> {
        let single: Single<Bool> = can(perform: action)
        return single.asPublisher()
    }
}

extension BlockchainAccount {
    public func fiatBalance(fiatCurrency: FiatCurrency) -> Single<MoneyValue> {
        balancePair(fiatCurrency: fiatCurrency).map(\.quote)
    }

    public func fiatBalance(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValue> {
        balancePair(fiatCurrency: fiatCurrency, at: date).map(\.quote)
    }
}

extension Publisher where Output == [SingleAccount] {

    /// Maps each `[SingleAccount]` object filtering out accounts that match the given `BlockchainAccount` identifier.
    public func mapFilter(excluding identifier: AnyHashable) -> AnyPublisher<Output, Failure> {
        map { accounts in
            accounts.filter { $0.identifier != identifier }
        }
        .eraseToAnyPublisher()
    }
}
