// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Localization
import RxSwift
import ToolKit

public protocol CryptoAssetRepositoryAPI {

    var allAccountsGroup: AnyPublisher<AccountGroup, Never> { get }

    var custodialGroup: AnyPublisher<AccountGroup, Never> { get }

    var nonCustodialGroup: AnyPublisher<AccountGroup, Never> { get }

    var exchangeGroup: AnyPublisher<AccountGroup, Never> { get }

    var interestGroup: AnyPublisher<AccountGroup, Never> { get }

    var canTransactToCustodial: AnyPublisher<Bool, Never> { get }

    func accountGroup(
        filter: AssetFilter
    ) -> AnyPublisher<AccountGroup, Never>

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never>
}

public final class CryptoAssetRepository: CryptoAssetRepositoryAPI {

    // MARK: - Types

    public typealias DefaultAccountProvider =
        () -> AnyPublisher<SingleAccount, CryptoAssetError>

    public typealias ExchangeAccountProvider =
        () -> AnyPublisher<CryptoExchangeAccount?, Never>

    // MARK: - Properties

    public var nonCustodialGroup: AnyPublisher<AccountGroup, Never> {
        let asset = self.asset
        return defaultAccountProvider()
            .map { account -> AccountGroup in
                CryptoAccountNonCustodialGroup(asset: asset, accounts: [account])
            }
            .recordErrors(on: errorRecorder)
            .replaceError(with: CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
            .eraseToAnyPublisher()
    }

    public var canTransactToCustodial: AnyPublisher<Bool, Never> {
        kycTiersService.tiers
            .asObservable()
            .asPublisher()
            .map { tiers in
                tiers.isTier1Approved || tiers.isTier2Approved
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    public var allAccountsGroup: AnyPublisher<AccountGroup, Never> {
        [
            nonCustodialGroup,
            custodialGroup,
            interestGroup,
            exchangeGroup
        ]
        .zip()
        .eraseToAnyPublisher()
        .flatMapAllAccountGroup()
    }

    public var exchangeGroup: AnyPublisher<AccountGroup, Never> {
        guard asset.assetModel.products.contains(.mercuryDeposits) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return exchangeAccount()
            .map { [asset] account -> CryptoAccountCustodialGroup in
                guard let account = account else {
                    return CryptoAccountCustodialGroup(asset: asset)
                }
                return CryptoAccountCustodialGroup(asset: asset, account: account)
            }
            .eraseToAnyPublisher()
    }

    public var interestGroup: AnyPublisher<AccountGroup, Never> {
        guard asset.assetModel.products.contains(.interestBalance) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(
            CryptoAccountCustodialGroup(
                asset: asset,
                account: CryptoInterestAccount(asset: asset)
            )
        )
    }

    public var custodialGroup: AnyPublisher<AccountGroup, Never> {
        guard asset.assetModel.products.contains(.custodialWalletBalance) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(
            CryptoAccountCustodialGroup(
                asset: asset,
                account: CryptoTradingAccount(asset: asset)
            )
        )
    }

    // MARK: - Private properties

    private lazy var exchangeAccount = { [asset, exchangeAccountsProvider] in
        exchangeAccountsProvider.account(for: asset)
            .asObservable()
            .asPublisher()
            .optional()
            .catch { error -> AnyPublisher<CryptoExchangeAccount?, Never> in
                // TODO: This shouldn't prevent users from seeing all accounts.
                // Potentially return nil should this fail.
                guard let serviceError = error as? ExchangeAccountsNetworkError else {
                    //                        #if INTERNAL_BUILD
                    //                        Logger.shared.error(error)
                    //                        throw error
                    //                        #else
                    //                        return .just(nil)
                    //                        #endif
                    return .just(nil)
                }
                switch serviceError {
                case .missingAccount:
                    return .just(nil)
                }
            }
            .eraseToAnyPublisher()
    }

    private let asset: CryptoCurrency
    private let errorRecorder: ErrorRecording
    private let kycTiersService: KYCTiersServiceAPI
    private let defaultAccountProvider: DefaultAccountProvider
    private let exchangeAccountsProvider: ExchangeAccountsProviderAPI
    private let addressFactory: CryptoReceiveAddressFactory

    // MARK: - Setup

    public init(
        asset: CryptoCurrency,
        errorRecorder: ErrorRecording,
        kycTiersService: KYCTiersServiceAPI,
        defaultAccountProvider: @escaping DefaultAccountProvider,
        exchangeAccountsProvider: ExchangeAccountsProviderAPI,
        addressFactory: CryptoReceiveAddressFactory
    ) {
        self.asset = asset
        self.errorRecorder = errorRecorder
        self.kycTiersService = kycTiersService
        self.defaultAccountProvider = defaultAccountProvider
        self.exchangeAccountsProvider = exchangeAccountsProvider
        self.addressFactory = addressFactory
    }

    // MARK: - Public methods

    public func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        switch filter {
        case .all:
            return allAccountsGroup
        case .custodial:
            return custodialGroup
        case .interest:
            return interestGroup
        case .nonCustodial:
            return nonCustodialGroup
        case .exchange:
            return exchangeGroup
        }
    }

    public func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        let receiveAddress = try? addressFactory
            .makeExternalAssetAddress(
                asset: asset,
                address: address,
                label: address,
                onTxCompleted: { _ in .empty() }
            )
            .get()
        return .just(receiveAddress)
    }
}
