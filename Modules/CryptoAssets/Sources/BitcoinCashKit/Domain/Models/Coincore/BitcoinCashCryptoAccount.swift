// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

final class BitcoinCashCryptoAccount: CryptoNonCustodialAccount {

    private(set) lazy var identifier: AnyHashable = "BitcoinCashCryptoAccount.\(xPub.address).\(xPub.derivationType)"
    let label: String
    let asset: CryptoCurrency = .coin(.bitcoinCash)
    let isDefault: Bool

    func createTransactionEngine() -> Any {
        BitcoinOnChainTransactionEngineFactory<BitcoinCashToken>()
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: .coin(.bitcoinCash)))
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: xPub)
            .moneyValue
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var actions: Single<AvailableActions> {
        isFunded
            .map { isFunded -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send, .buy]
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        let receiveAddress: Single<String> = bridge.receiveAddress(forXPub: xPub.address)
        let account: Single<BitcoinCashWalletAccount> = bridge
            .wallets
            .map { [xPub] wallets in
                wallets.filter { $0.publicKey == xPub }
            }
            .map { accounts -> BitcoinCashWalletAccount in
                guard let account = accounts.first else {
                    throw PlatformKitError.illegalStateException(message: "Expected a BitcoinCashWalletAccount")
                }
                return account
            }

        return Single.zip(receiveAddress, account)
            .map { [label, onTxCompleted] address, account -> ReceiveAddress in
                BitcoinChainReceiveAddress<BitcoinCashToken>(
                    address: address,
                    label: label,
                    onTxCompleted: onTxCompleted,
                    index: Int32(account.index)
                )
            }
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        transactionsService
            .transactions(publicKeys: [xPub])
            .map { response in
                response
                    .map(\.activityItemEvent)
            }
            .catchErrorJustReturn([])
    }

    private var swapActivity: Single<[SwapActivityItemEvent]> {
        swapTransactionsService
            .fetchActivity(cryptoCurrency: asset, directions: custodialDirections)
            .catchErrorJustReturn([])
    }

    private let xPub: XPub
    private let hdAccountIndex: Int
    private let balanceService: BalanceServiceAPI
    private let fiatPriceService: FiatPriceServiceAPI
    private let bridge: BitcoinCashWalletBridgeAPI
    private let transactionsService: BitcoinCashHistoricalTransactionServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI

    init(
        xPub: XPub,
        label: String?,
        isDefault: Bool,
        hdAccountIndex: Int,
        fiatPriceService: FiatPriceServiceAPI = resolve(),
        transactionsService: BitcoinCashHistoricalTransactionServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        balanceService: BalanceServiceAPI = resolve(tag: BitcoinChainCoin.bitcoinCash),
        bridge: BitcoinCashWalletBridgeAPI = resolve()
    ) {
        self.xPub = xPub
        self.label = label ?? CryptoCurrency.coin(.bitcoinCash).defaultWalletName
        self.isDefault = isDefault
        self.hdAccountIndex = hdAccountIndex
        self.fiatPriceService = fiatPriceService
        self.balanceService = balanceService
        self.transactionsService = transactionsService
        self.swapTransactionsService = swapTransactionsService
        self.bridge = bridge
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .send,
             .buy,
             .viewActivity:
            return .just(true)
        case .deposit,
             .withdraw,
             .sell:
            return .just(false)
        case .swap:
            return isFunded
        }
    }

    func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency),
                balance
            )
            .map { fiatPrice, balance in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }

    func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency, date: date),
                balance
            )
            .map { fiatPrice, balance in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }

    func updateLabel(_ newLabel: String) -> Completable {
        bridge.update(accountIndex: hdAccountIndex, label: newLabel)
    }
}
