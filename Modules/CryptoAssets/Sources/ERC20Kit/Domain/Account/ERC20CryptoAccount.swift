// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20CryptoAccount: CryptoNonCustodialAccount {
    private(set) lazy var identifier: AnyHashable = "ERC20CryptoAccount.\(asset.code).\(publicKey)"
    let label: String
    let asset: CryptoCurrency
    let isDefault: Bool = true

    func createTransactionEngine() -> Any {
        ERC20OnChainTransactionEngineFactory(erc20Token: erc20Token)
    }

    var actionableBalance: Single<MoneyValue> {
        balance
    }

    var balance: Single<MoneyValue> {
        balanceService
            .balance(for: EthereumAddress(address: publicKey)!, cryptoCurrency: asset)
            .asSingle()
            .moneyValue
    }

    var pendingBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    var actions: Single<AvailableActions> {
        Single
            .zip(isFunded, isPairToFiatAvailable)
            .map { isFunded, isPairToFiatAvailable -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive, .send]
                if isPairToFiatAvailable {
                    base.insert(.buy)
                }
                if isFunded {
                    base.insert(.swap)
                }
                return base
            }
    }

    var receiveAddress: Single<ReceiveAddress> {
        .just(ERC20ReceiveAddress(asset: asset, address: publicKey, label: label, onTxCompleted: onTxCompleted))
    }

    var activity: Single<[ActivityItemEvent]> {
        Single.zip(nonCustodialActivity, swapActivity)
            .map { nonCustodialActivity, swapActivity in
                Self.reconcile(swapEvents: swapActivity, noncustodial: nonCustodialActivity)
            }
    }

    private var nonCustodialActivity: Single<[TransactionalActivityItemEvent]> {
        transactionsService
            .transactions(erc20Asset: erc20Token, address: EthereumAddress(address: publicKey)!)
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

    private let publicKey: String
    private let erc20Token: ERC20AssetModel
    private let balanceService: ERC20BalanceServiceAPI
    private let featureFetcher: FeatureFetching
    private let fiatPriceService: FiatPriceServiceAPI
    private let transactionsService: ERC20HistoricalTransactionServiceAPI
    private let swapTransactionsService: SwapActivityServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI

    init(
        publicKey: String,
        erc20Token: ERC20AssetModel,
        featureFetcher: FeatureFetching = resolve(),
        balanceService: ERC20BalanceServiceAPI = resolve(),
        transactionsService: ERC20HistoricalTransactionServiceAPI = resolve(),
        fiatPriceService: FiatPriceServiceAPI = resolve(),
        swapTransactionsService: SwapActivityServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve()
    ) {
        self.publicKey = publicKey
        self.erc20Token = erc20Token
        asset = erc20Token.cryptoCurrency
        label = erc20Token.cryptoCurrency.defaultWalletName
        self.balanceService = balanceService
        self.featureFetcher = featureFetcher
        self.transactionsService = transactionsService
        self.swapTransactionsService = swapTransactionsService
        self.fiatPriceService = fiatPriceService
        self.supportedPairsInteractorService = supportedPairsInteractorService
    }

    private var isPairToFiatAvailable: Single<Bool> {
        supportedPairsInteractorService
            .pairs
            .take(1)
            .asSingle()
            .map { [asset] pairs in
                pairs.cryptoCurrencySet.contains(asset)
            }
            .catchErrorJustReturn(false)
    }

    func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .receive,
             .viewActivity,
             .send:
            return .just(true)
        case .deposit,
             .withdraw:
            return .just(false)
        case .buy:
            return isPairToFiatAvailable
        case .sell:
            return .just(false)
//            return Single.zip(isPairToFiatAvailable, isFunded).map {
//                $0.0 && $0.1
//            }
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
}
