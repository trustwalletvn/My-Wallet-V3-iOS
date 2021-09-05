// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public protocol BlockchainAccountProviding: AnyObject {
    func accounts(for currency: CurrencyType) -> Single<[BlockchainAccount]>
    func accounts(accountType: SingleAccountType) -> Single<[BlockchainAccount]>
    func accounts(for currency: CurrencyType, accountType: SingleAccountType) -> Single<[BlockchainAccount]>
    func account(for currency: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount>
}

public enum BlockchainAccountProvidingError: Error {
    case doesNotExist
}

final class BlockchainAccountProvider: BlockchainAccountProviding {
    private let coincore: CoincoreAPI

    init(coincore: CoincoreAPI = resolve()) {
        self.coincore = coincore
    }

    func accounts(for currency: CurrencyType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts
            .map { $0.accounts.filter { $0.currencyType == currency } }
            .catchErrorJustReturn([])
    }

    func accounts(accountType: SingleAccountType) -> Single<[BlockchainAccount]> {
        coincore
            .allAccounts
            .map(\.accounts)
            .map { accounts in
                accounts.filter { account in
                    switch accountType {
                    case .nonCustodial:
                        return account is NonCustodialAccount
                    case .custodial(let type):
                        switch type {
                        case .savings:
                            return account is CryptoInterestAccount
                        case .trading:
                            return account is TradingAccount
                        }
                    }
                }
            }
            .catchErrorJustReturn([])
    }

    func accounts(for currency: CurrencyType, accountType: SingleAccountType) -> Single<[BlockchainAccount]> {
        switch currency {
        case .fiat:
            return coincore.fiatAsset
                .accountGroup(filter: .all)
                .map(\.accounts)
                .map { accounts in
                    accounts.filter { $0.currencyType == currency }
                }
                .map { accounts in
                    accounts as [BlockchainAccount]
                }
                .catchErrorJustReturn([])
        case .crypto(let cryptoCurrency):
            guard let cryptoAsset = coincore.cryptoAssets.first(where: { $0.asset == cryptoCurrency }) else {
                return .just([])
            }
            let filter: AssetFilter

            switch accountType {
            case .nonCustodial:
                filter = .nonCustodial
            case .custodial(let type):
                switch type {
                case .savings:
                    filter = .interest
                case .trading:
                    filter = .custodial
                }
            }
            return cryptoAsset
                .accountGroup(filter: filter)
                .map(\.accounts)
                .map { accounts in
                    accounts.filter { $0.currencyType == currency }
                }
                .map { accounts in
                    accounts as [BlockchainAccount]
                }
                .catchErrorJustReturn([])
        }
    }

    func account(for currency: CurrencyType, accountType: SingleAccountType) -> Single<BlockchainAccount> {
        accounts(for: currency, accountType: accountType)
            .flatMap { accounts in
                guard let value = accounts.first else {
                    return .error(BlockchainAccountProvidingError.doesNotExist)
                }
                return .just(value)
            }
    }
}
