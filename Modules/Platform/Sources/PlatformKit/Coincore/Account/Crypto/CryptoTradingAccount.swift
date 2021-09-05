// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

/// Named `CustodialTradingAccount` on Android
public class CryptoTradingAccount: CryptoAccount, TradingAccount {

    private enum Error: LocalizedError {
        case loadingFailed(asset: String, label: String, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let asset, let label, let action, let error):
                return "Failed to load: 'CryptoTradingAccount' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)' ."
            }
        }
    }

    public private(set) lazy var identifier: AnyHashable = "CryptoTradingAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var receiveAddress: Single<ReceiveAddress> {
        custodialAddressService
            .receiveAddress(for: asset)
            .flatMap(weak: self) { (self, address) in
                self.cryptoReceiveAddressFactory.makeExternalAssetAddress(
                    asset: self.asset,
                    address: address,
                    label: self.label,
                    onTxCompleted: self.onTxCompleted
                )
                .single
                .map { $0 as ReceiveAddress }
            }
    }

    public var isFunded: Single<Bool> {
        balances.map { $0 != .absent }
    }

    public var pendingBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.pending)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var balance: Single<MoneyValue> {
        balances
            .map(\.balance?.available)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var actionableBalance: Single<MoneyValue> {
        balances
            .map(\.balance)
            .map { [asset] balance -> (available: MoneyValue, pending: MoneyValue) in
                guard let balance = balance else {
                    return (.zero(currency: asset), .zero(currency: asset))
                }
                return (balance.available, balance.pending)
            }
            .map { [asset] values -> MoneyValue in
                guard values.available.isPositive else {
                    return .zero(currency: asset)
                }
                return try values.available - values.pending
            }
    }

    public var withdrawableBalance: Single<MoneyValue> {
        balances
            .map(\.balance?.withdrawable)
            .onNilJustReturn(.zero(currency: currencyType))
    }

    public var onTxCompleted: (TransactionResult) -> Completable {
        { [weak self] result -> Completable in
            guard let self = self else {
                return .error(PlatformKitError.default)
            }
            guard case .hashed(let hash, let amount) = result else {
                return .error(PlatformKitError.default)
            }
            guard amount.isCrypto else {
                return .error(PlatformKitError.default)
            }
            return self.receiveAddress
                .flatMapCompletable(weak: self) { (self, receiveAddress) -> Completable in
                    self.custodialPendingDepositService.createPendingDeposit(
                        value: amount,
                        destination: receiveAddress.address,
                        transactionHash: hash,
                        product: "SIMPLEBUY"
                    )
                }
        }
    }

    public var actions: Single<AvailableActions> {
        Single.zip(balance, eligibilityService.isEligible, isPairToFiatAvailable)
            .map { balance, isEligible, isPairToFiatAvailable -> AvailableActions in
                var base: AvailableActions = [.viewActivity, .receive]
                if isPairToFiatAvailable {
                    base.insert(.buy)
                }
                if balance.isPositive {
                    base.insert(.send)
                }
                if balance.isPositive, isEligible {
                    base.insert(.sell)
                    base.insert(.swap)
                }
                return base
            }
    }

    public var activity: Single<[ActivityItemEvent]> {
        Single
            .zip(
                buySellActivity.buySellActivityEvents(cryptoCurrency: asset),
                ordersActivity.activity(cryptoCurrency: asset).catchErrorJustReturn([]),
                swapActivity.fetchActivity(cryptoCurrency: asset, directions: [.internal]).catchErrorJustReturn([])
            )
            .map { buySellActivity, ordersActivity, swapActivity -> [ActivityItemEvent] in
                buySellActivity.map(ActivityItemEvent.buySell)
                    + ordersActivity.map(ActivityItemEvent.crypto)
                    + swapActivity.map(ActivityItemEvent.swap)
            }
    }

    private let balanceService: TradingBalanceServiceAPI
    private let cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService
    private let custodialAddressService: CustodialAddressServiceAPI
    private let custodialPendingDepositService: CustodialPendingDepositServiceAPI
    private let eligibilityService: EligibilityServiceAPI
    private let errorRecorder: ErrorRecording
    private let fiatPriceService: FiatPriceServiceAPI
    private let featureFetcher: FeatureFetching
    private let kycTiersService: KYCTiersServiceAPI
    private let ordersActivity: OrdersActivityServiceAPI
    private let swapActivity: SwapActivityServiceAPI
    private let buySellActivity: BuySellActivityItemEventServiceAPI
    private let supportedPairsInteractorService: SupportedPairsInteractorServiceAPI

    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset.currency)
    }

    public init(
        asset: CryptoCurrency,
        swapActivity: SwapActivityServiceAPI = resolve(),
        ordersActivity: OrdersActivityServiceAPI = resolve(),
        buySellActivity: BuySellActivityItemEventServiceAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        fiatPriceService: FiatPriceServiceAPI = resolve(),
        balanceService: TradingBalanceServiceAPI = resolve(),
        cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService = resolve(),
        custodialAddressService: CustodialAddressServiceAPI = resolve(),
        custodialPendingDepositService: CustodialPendingDepositServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        supportedPairsInteractorService: SupportedPairsInteractorServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.asset = asset
        label = asset.defaultTradingWalletName
        self.ordersActivity = ordersActivity
        self.swapActivity = swapActivity
        self.buySellActivity = buySellActivity
        self.fiatPriceService = fiatPriceService
        self.balanceService = balanceService
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
        self.custodialAddressService = custodialAddressService
        self.custodialPendingDepositService = custodialPendingDepositService
        self.eligibilityService = eligibilityService
        self.featureFetcher = featureFetcher
        self.kycTiersService = kycTiersService
        self.errorRecorder = errorRecorder
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

    public func can(perform action: AssetAction) -> Single<Bool> {
        switch action {
        case .viewActivity:
            return .just(true)
        case .send:
            return balance
                .map(\.isPositive)
                .catchError { [label, asset] error in
                    throw Error.loadingFailed(
                        asset: asset.code,
                        label: label,
                        action: action,
                        error: String(describing: error)
                    )
                }
                .recordErrors(on: errorRecorder)
                .catchErrorJustReturn(false)
        case .buy:
            return isPairToFiatAvailable
        case .sell,
             .swap:
            return balance
                .map(\.isPositive)
                .flatMap(weak: self) { (self, isPositive) -> Single<Bool> in
                    guard isPositive else {
                        return .just(false)
                    }
                    return self.eligibilityService.isEligible
                }
                .catchError { [label, asset] error in
                    throw Error.loadingFailed(
                        asset: asset.code,
                        label: label,
                        action: action,
                        error: String(describing: error)
                    )
                }
                .recordErrors(on: errorRecorder)
                .catchErrorJustReturn(false)
        case .receive:
            return .just(true)
        case .deposit,
             .withdraw:
            return .just(false)
        }
    }

    public func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        Single
            .zip(
                fiatPriceService.getPrice(cryptoCurrency: asset, fiatCurrency: fiatCurrency),
                balance
            )
            .map { fiatPrice, balance in
                try MoneyValuePair(base: balance, exchangeRate: fiatPrice)
            }
    }

    public func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
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
