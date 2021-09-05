// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import RxSwift
import ToolKit

/// Types adopting the `CoincoreAPI` should provide a way to retrieve fiat and crypto accounts
public protocol CoincoreAPI {
    /// Provides access to fiat and crypto custodial and non custodial assets.
    var allAccounts: Single<AccountGroup> { get }
    var allAssets: [Asset] { get }
    var fiatAsset: Asset { get }
    var cryptoAssets: [CryptoAsset] { get }

    /// Initialize any assets prior being available
    func initialize() -> Completable
    func initializePublisher() -> AnyPublisher<Never, Never>

    /// Provides an array of `SingleAccount` instances for the specified source account and the given action.
    /// - Parameters:
    ///   - sourceAccount: A `BlockchainAccount` to be used as the source account
    ///   - action: An `AssetAction` to determine the transaction targets
    func getTransactionTargets(sourceAccount: BlockchainAccount, action: AssetAction) -> Single<[SingleAccount]>

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset { get }
}

final class Coincore: CoincoreAPI {

    // MARK: - Public Properties

    var allAccounts: Single<AccountGroup> {
        reactiveWallet.waitUntilInitializedSingle
            .flatMap(weak: self) { (self, _) in
                Single.zip(
                    self.allAssets.map { asset in asset.accountGroup(filter: .all) }
                )
            }
            .map { accountGroups -> [SingleAccount] in
                accountGroups
                    .map(\.accounts)
                    .reduce(into: [SingleAccount]()) { result, accounts in
                        result.append(contentsOf: accounts)
                    }
            }
            .map { accounts -> AccountGroup in
                AllAccountsGroup(accounts: accounts)
            }
    }

    // MARK: - Private Properties

    var allAssets: [Asset] {
        [fiatAsset] + cryptoAssets
    }

    let fiatAsset: Asset
    let cryptoAssets: [CryptoAsset]

    private let reactiveWallet: ReactiveWalletAPI

    // MARK: - Setup

    init(
        cryptoAssets: [CryptoAsset],
        fiatAsset: FiatAsset = FiatAsset(),
        reactiveWallet: ReactiveWalletAPI = resolve()
    ) {
        self.cryptoAssets = cryptoAssets.sorted(by: { $0.asset < $1.asset })
        self.fiatAsset = fiatAsset
        self.reactiveWallet = reactiveWallet
    }

    /// Gives a chance for all assets to initialize themselves.
    func initialize() -> Completable {
        var completables = cryptoAssets
            .map { asset -> Completable in
                asset.initialize()
            }
        completables.append(fiatAsset.initialize())
        return Completable.concat(completables)
    }

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        guard let asset = cryptoAssets.first(where: { $0.asset == cryptoCurrency }) else {
            fatalError("Unknown crypto currency '\(cryptoCurrency.code)'.")
        }
        return asset
    }

    /// We are looking for targets of our action.
    /// Action is considered what the source account wants to do.
    func getTransactionTargets(
        sourceAccount: BlockchainAccount,
        action: AssetAction
    ) -> Single<[SingleAccount]> {
        switch action {
        case .swap:
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected CryptoAccount: \(sourceAccount)")
            }
            return allAccounts
                .map(\.accounts)
                .map { accounts -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        Self.getActionFilter(
                            sourceAccount: cryptoAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
        case .send:
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected CryptoAccount: \(sourceAccount)")
            }
            return self[cryptoAccount.asset]
                .transactionTargets(account: cryptoAccount)
                .map { accounts -> [SingleAccount] in
                    accounts.filter { destinationAccount -> Bool in
                        Self.getActionFilter(
                            sourceAccount: cryptoAccount,
                            destinationAccount: destinationAccount,
                            action: action
                        )
                    }
                }
        case .buy:
            unimplemented("WIP")
        case .deposit,
             .receive,
             .sell,
             .viewActivity,
             .withdraw:
            unimplemented("\(action) is not supported.")
        }
    }

    private static func getActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        switch action {
        case .buy:
            unimplemented("WIP")
        case .sell:
            return destinationAccount is FiatAccount
        case .swap:
            return swapActionFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .send:
            return sendActionFilter(
                sourceAccount: sourceAccount,
                destinationAccount: destinationAccount,
                action: action
            )
        case .deposit,
             .receive,
             .viewActivity,
             .withdraw:
            return false
        }
    }

    private static func swapActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType != sourceAccount.currencyType else {
            return false
        }
        switch (sourceAccount, destinationAccount) {
        case (is CryptoTradingAccount, is CryptoTradingAccount),
             (is CryptoNonCustodialAccount, is CryptoTradingAccount),
             (is CryptoNonCustodialAccount, is CryptoNonCustodialAccount):
            return true
        default:
            return false
        }
    }

    private static func sendActionFilter(
        sourceAccount: CryptoAccount,
        destinationAccount: SingleAccount,
        action: AssetAction
    ) -> Bool {
        guard destinationAccount.currencyType == sourceAccount.currencyType else {
            return false
        }
        switch destinationAccount {
        case is CryptoTradingAccount,
             is CryptoExchangeAccount,
             is CryptoNonCustodialAccount:
            return true
        default:
            return false
        }
    }
}

// MARK: - Combine Related Methods

extension CoincoreAPI {
    /// Gives a chance for all assets to initialize themselves.
    /// - Note: Uses the `initialize` method and converts it to a publisher.
    public func initializePublisher() -> AnyPublisher<Never, Never> {
        initialize()
            .asPublisher()
            .catch { _ -> AnyPublisher<Never, Never> in
                impossible()
            }
            .ignoreFailure()
    }
}
