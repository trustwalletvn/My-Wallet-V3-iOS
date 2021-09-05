// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift
import ToolKit

extension PrimitiveSequenceType where Trait == SingleTrait, Element == [BlockchainAccount] {
    /// Filters an `[BlockchainAccount]` for only `BlockchainAccount`s that can perform the given action.
    /// - parameter failSequence: When `true` re-throws errors raised by any `BlockchainAccount.can(perform:)`. If this is set to `false`, filters out from the emitted element any account whose `BlockchainAccount.can(perform:)` failed.
    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool,
        onError: ((BlockchainAccount, Error) -> Void)? = nil
    ) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<BlockchainAccount?>] = accounts.map { account in
                // Check if account can perform action
                account.can(perform: action)
                    // If account can perform, return itself, else return nil
                    .map { $0 ? account : nil }
                    .catchError { error -> Single<BlockchainAccount?> in
                        onError?(account, error)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }

            return Single.zip(elements)
                // Filter nil elements (accounts that can't perform action)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait, Element == [SingleAccount] {
    /// Filters an `[SingleAccount]` for only `SingleAccount`s that can perform the given action.
    /// - parameter failSequence: When `true` re-throws errors raised by any `BlockchainAccount.can(perform:)`. If this is set to `false`, filters out from the emitted element any account whose `BlockchainAccount.can(perform:)` failed.
    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool,
        onError: ((SingleAccount, Error) -> Void)? = nil
    ) -> PrimitiveSequence<SingleTrait, Element> {
        flatMap { accounts -> Single<Element> in
            let elements: [Single<SingleAccount?>] = accounts.map { account in
                // Check if account can perform action
                account.can(perform: action)
                    // If account can perform, return itself, else return nil
                    .map { $0 ? account : nil }
                    .catchError { error -> Single<SingleAccount?> in
                        onError?(account, error)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
            }
            return Single.zip(elements)
                // Filter nil elements (accounts that can't perform action)
                .map { accounts -> Element in
                    accounts.compactMap { $0 }
                }
        }
    }

    /// Maps each `[SingleAccount]` object filtering out accounts that match the given `BlockchainAccount` identifier.
    public func mapFilter(excluding identifier: AnyHashable) -> PrimitiveSequence<SingleTrait, Element> {
        map { accounts in
            accounts.filter { $0.identifier != identifier }
        }
    }
}

extension AccountGroup {

    public func accounts(
        supporting action: AssetAction,
        failSequence: Bool = false,
        onError: ((SingleAccount, Error) -> Void)? = nil
    ) -> Single<[SingleAccount]> {
        accountsPublisher(
            supporting: action,
            failSequence: failSequence,
            onError: onError
        )
        .asObservable()
        .asSingle()
    }

    public func accountsPublisher(
        supporting action: AssetAction,
        failSequence: Bool = false,
        onError: ((SingleAccount, Error) -> Void)? = nil
    ) -> AnyPublisher<[SingleAccount], Error> {
        .just(accounts)
            .flatMapFilter(
                action: action,
                failSequence: failSequence,
                onError: onError
            )
    }
}

extension Publisher where Output == [SingleAccount], Failure == Error {

    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool = false,
        onError: ((SingleAccount, Failure) -> Void)? = nil
    ) -> AnyPublisher<[SingleAccount], Failure> {
        flatMap { accounts -> AnyPublisher<[SingleAccount], Failure> in
            accounts.map { account in
                // Check if account can perform action
                account.can(perform: action)
                    // If account can perform, return itself, else return nil
                    .map { $0 ? account : nil }
                    .tryCatch { error -> AnyPublisher<SingleAccount?, Failure> in
                        Logger.shared.error(
                            "[Coincore] Error checking if account can perform '\(action)' => \(error)"
                        )
                        onError?(account, error)
                        if failSequence {
                            throw error
                        }
                        return .just(nil)
                    }
                    .eraseToAnyPublisher()
            }
            .zip()
            // Filter nil elements (accounts that can't perform action)
            .map { accounts in
                accounts.compactMap { $0 }
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == AccountGroup, Failure == Error {

    public func flatMapFilter(
        action: AssetAction,
        failSequence: Bool = false,
        onError: ((SingleAccount, Failure) -> Void)? = nil
    ) -> AnyPublisher<[SingleAccount], Failure> {
        map(\.accounts)
            .flatMapFilter(
                action: action,
                failSequence: failSequence,
                onError: onError
            )
    }

    fileprivate func mapToCryptoAccounts(supporting action: AssetAction) -> AnyPublisher<[CryptoAccount], Failure> {
        flatMapFilter(action: action)
            .map { accounts in
                accounts
                    .compactMap { $0 as? CryptoAccount }
                    .sorted { lhs, rhs in
                        lhs.asset < rhs.asset
                    }
            }
            .eraseToAnyPublisher()
    }
}

extension CoincoreAPI {

    public func cryptoAccounts(supporting action: AssetAction) -> AnyPublisher<[CryptoAccount], Error> {
        allAccounts
            .asPublisher()
            .mapToCryptoAccounts(supporting: action)
    }

    public func cryptoAccounts(
        for cryptoCurrency: CryptoCurrency,
        supporting action: AssetAction,
        filter: AssetFilter = .all
    ) -> AnyPublisher<[CryptoAccount], Error> {
        let asset = self[cryptoCurrency]
        return asset.accountGroup(filter: filter)
            .asPublisher()
            .mapToCryptoAccounts(supporting: action)
    }

    public var uniqueCryptoAccountsByAssetThatSupportBuy: AnyPublisher<[CryptoAccount], Error> {
        cryptoAccounts(supporting: .buy)
            .map { accounts in
                var dictionary: [CryptoCurrency: CryptoAccount] = [:]
                for account in accounts {
                    dictionary[account.asset] = account
                }
                return Array(dictionary.values)
                    .sorted { lhs, rhs in
                        lhs.asset < rhs.asset
                    }
            }
            .eraseToAnyPublisher()
    }
}
