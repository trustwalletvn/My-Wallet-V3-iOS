// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
import PlatformKit
import RxRelay
import RxSwift

enum EthereumWalletBridgeMockError: Error {
    case mockError
}

class EthereumWalletBridgeMock: EthereumWalletBridgeAPI,
    EthereumWalletAccountBridgeAPI,
    MnemonicAccessAPI,
    PasswordAccessAPI
{
    func update(accountIndex: Int, label: String) -> Completable {
        .empty()
    }

    var balance: Single<CryptoValue> {
        balanceValue
    }

    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        .empty()
    }

    func memo(for transactionHash: String) -> Single<String?> {
        .just(nil)
    }

    var historyValue = Single.just(())
    var history: Single<Void> {
        historyValue
    }

    func fetchHistory() -> Single<Void> {
        history
    }

    var fetchBalanceValue: Single<CryptoValue> = Single.just(CryptoValue.create(major: "2.0", currency: .coin(.ethereum))!)
    var fetchBalance: Single<CryptoValue> {
        fetchBalanceValue
    }

    var balanceValue: Single<CryptoValue> = Single.just(CryptoValue.create(major: "2.0", currency: .coin(.ethereum))!)

    var balanceMoneyObservable: Observable<MoneyValue> {
        balance.asObservable().moneyValue
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    var nameValue: Single<String> = Single.just(CryptoCurrency.coin(.ethereum).defaultWalletName)
    var name: Single<String> {
        nameValue
    }

    var addressValue: Single<EthereumAddress> = .just(EthereumAddress(address: MockEthereumWalletTestData.account)!)
    var address: Single<EthereumAddress> {
        addressValue
    }

    var transactionsValue: Single<[EthereumHistoricalTransaction]> = Single.just([])
    var transactions: Single<[EthereumHistoricalTransaction]> {
        transactionsValue
    }

    var accountValue: Single<EthereumAssetAccount> = Single.just(
        EthereumAssetAccount(
            walletIndex: 0,
            accountAddress: MockEthereumWalletTestData.account,
            name: CryptoCurrency.coin(.ethereum).defaultWalletName
        )
    )
    var account: Single<EthereumAssetAccount> {
        accountValue
    }

    var recordLastTransactionValue = Single<EthereumTransactionPublished>.error(EthereumKitError.unknown)
    var lastRecordedTransaction: EthereumTransactionPublished?

    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        lastRecordedTransaction = transaction
        return recordLastTransactionValue
    }

    // MARK: - EthereumWalletAccountBridgeAPI

    var wallets: Single<[EthereumWalletAccount]> {
        Single.just([])
    }

    func save(keyPair: EthereumKeyPair, label: String) -> Completable {
        Completable.empty()
    }

    // MARK: - MnemonicAccessAPI

    var mnemonic: Maybe<String> {
        Maybe.just("")
    }

    var mnemonicPromptingIfNeeded: Maybe<String> {
        Maybe.just("")
    }

    func mnemonic(with secondPassword: String?) -> Single<Mnemonic> {
        .just("")
    }

    // MARK: - PasswordAccessAPI

    var passwordMaybe = Maybe.just("password")
    var password: Maybe<String> {
        passwordMaybe
    }
}
