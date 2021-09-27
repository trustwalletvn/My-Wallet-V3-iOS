// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import ERC20Kit
import EthereumKit
import PlatformKit
import RxRelay
import RxSwift

class ERC20EthereumWalletBridgeMock: EthereumWalletBridgeAPI {

    let cryptoCurrency: CryptoCurrency

    var balanceValue: CryptoValue
    var isWaitingOnTransactionValue = Single.just(true)
    var historyValue = Single.just(())
    var addressValue: Single<EthereumAddress> = .just(
        EthereumAddress(address: "0x0000000000000000000000000000000000000000")!
    )
    var nameValue: Single<String> = Single.just("")
    var transactionsValue: Single<[EthereumHistoricalTransaction]> = Single.just([])
    var accountValue = EthereumAssetAccount(walletIndex: 0, accountAddress: "", name: "")
    var nonceValue = Single.just(BigUInt(1))

    init(cryptoCurrency: CryptoCurrency) {
        self.cryptoCurrency = cryptoCurrency
        balanceValue = .create(major: 2, currency: cryptoCurrency)
    }

    func update(accountIndex: Int, label: String) -> Completable {
        .empty()
    }

    func updateMemo(for transactionHash: String, memo: String?) -> Completable {
        .empty()
    }

    func memo(for transactionHash: String) -> Single<String?> {
        .just(nil)
    }

    var history: Single<Void> {
        historyValue
    }

    func fetchHistory() -> Single<Void> {
        history
    }

    var balance: Single<CryptoValue> {
        .just(balanceValue)
    }

    var balanceMoneyObservable: Observable<MoneyValue> {
        balance.asObservable().moneyValue
    }

    let balanceFetchTriggerRelay = PublishRelay<Void>()

    var name: Single<String> {
        nameValue
    }

    var address: Single<EthereumAddress> {
        addressValue
    }

    var transactions: Single<[EthereumHistoricalTransaction]> {
        transactionsValue
    }

    var account: Single<EthereumAssetAccount> {
        .just(accountValue)
    }

    var nonce: Single<BigUInt> {
        nonceValue
    }

    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        .just(transaction)
    }
}
