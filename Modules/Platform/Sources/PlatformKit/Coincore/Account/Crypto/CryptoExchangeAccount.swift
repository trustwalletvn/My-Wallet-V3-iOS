// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

/// State of Exchange account linking
public enum ExchangeAccountState: String {
    case pending = "PENDING"
    case active = "ACTIVE"
    case blocked = "BLOCKED"

    /// Returns `true` for an active state
    public var isActive: Bool {
        switch self {
        case .active:
            return true
        case .pending, .blocked:
            return false
        }
    }

    // MARK: - Init

    init(state: CryptoExchangeAddressResponse.State) {
        switch state {
        case .active:
            self = .active
        case .blocked:
            self = .blocked
        case .pending:
            self = .pending
        }
    }
}

public protocol ExchangeAccount: CryptoAccount {
    var state: ExchangeAccountState { get }
}

public final class CryptoExchangeAccount: ExchangeAccount {

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var actionableBalance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    public var balance: Single<MoneyValue> {
        .just(.zero(currency: asset))
    }

    public var receiveAddress: Single<ReceiveAddress> {
        cryptoReceiveAddressFactory
            .makeExternalAssetAddress(
                asset: asset,
                address: address,
                label: label,
                onTxCompleted: onTxCompleted
            )
            .single
            .map { $0 as ReceiveAddress }
    }

    public var pendingBalance: Single<MoneyValue> {
        /// Exchange API does not return a balance.
        .just(.zero(currency: asset))
    }

    public var actions: Single<AvailableActions> {
        .just([])
    }

    public var isFunded: Single<Bool> {
        .just(true)
    }

    public var activity: Single<[ActivityItemEvent]> {
        .just([])
    }

    public private(set) lazy var identifier: AnyHashable = "CryptoExchangeAccount." + asset.code
    public let asset: CryptoCurrency
    public let isDefault: Bool = false
    public let label: String
    public let state: ExchangeAccountState

    public func balancePair(fiatCurrency: FiatCurrency) -> Single<MoneyValuePair> {
        /// Exchange API does not return a balance.
        .just(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currency))
    }

    public func balancePair(fiatCurrency: FiatCurrency, at date: Date) -> Single<MoneyValuePair> {
        /// Exchange API does not return a balance.
        .just(.zero(baseCurrency: currencyType, quoteCurrency: fiatCurrency.currency))
    }

    public func can(perform action: AssetAction) -> Single<Bool> {
        .just(false)
    }

    // MARK: - Private Properties

    private let address: String
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService

    // MARK: - Init

    init(
        response: CryptoExchangeAddressResponse,
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        cryptoReceiveAddressFactory: CryptoReceiveAddressFactoryService = resolve()
    ) {
        label = response.assetType.defaultExchangeWalletName
        asset = response.assetType
        address = response.address
        state = .init(state: response.state)
        self.exchangeAccountProvider = exchangeAccountProvider
        self.cryptoReceiveAddressFactory = cryptoReceiveAddressFactory
    }

    static func from(response: CryptoExchangeAddressResponse) -> Self {
        Self(response: response)
    }
}
