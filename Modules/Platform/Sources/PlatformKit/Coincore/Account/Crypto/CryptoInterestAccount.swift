// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

public final class CryptoInterestAccount: CryptoAccount, InterestAccount {
    public private(set) lazy var identifier: AnyHashable = "CryptoInterestAccount." + asset.code
    public let label: String
    public let asset: CryptoCurrency
    public let isDefault: Bool = false

    public var receiveAddress: Single<ReceiveAddress> {
        .error(ReceiveAddressError.notSupported)
    }

    public var requireSecondPassword: Single<Bool> {
        .just(false)
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
        balance
    }

    public var actions: Single<AvailableActions> {
        .just([])
    }

    public var activity: Single<[ActivityItemEvent]> {
        .just([])
    }

    private let fiatPriceService: FiatPriceServiceAPI
    private let balanceService: InterestAccountOverviewAPI
    private var balances: Single<CustodialAccountBalanceState> {
        balanceService.balance(for: asset)
    }

    public init(
        asset: CryptoCurrency,
        fiatPriceService: FiatPriceServiceAPI = resolve(),
        balanceService: InterestAccountOverviewAPI = resolve(),
        exchangeProviding: ExchangeProviding = resolve()
    ) {
        label = asset.defaultInterestWalletName
        self.asset = asset
        self.balanceService = balanceService
        self.fiatPriceService = fiatPriceService
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(false)
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
