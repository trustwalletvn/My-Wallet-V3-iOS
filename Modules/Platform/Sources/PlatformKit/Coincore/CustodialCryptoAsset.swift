// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

final class CustodialCryptoAsset: CryptoAsset {

    var defaultAccount: Single<SingleAccount> {
        .error(CryptoAssetError.noDefaultAccount)
    }

    let asset: CryptoCurrency
    let kycTiersService: KYCTiersServiceAPI
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let addressFactory: PlainCryptoReceiveAddressFactory

    init(
        asset: CryptoCurrency,
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        addressFactory: PlainCryptoReceiveAddressFactory = .init()
    ) {
        self.asset = asset
        self.kycTiersService = kycTiersService
        self.exchangeAccountProvider = exchangeAccountProvider
        self.addressFactory = addressFactory
    }

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup> {
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

    private var allAccountsGroup: Single<AccountGroup> {
        Single
            .zip([
                custodialGroup,
                interestGroup,
                exchangeGroup,
                nonCustodialGroup
            ])
            .flatMapAllAccountGroup()
    }

    private var exchangeGroup: Single<AccountGroup> {
        guard asset.assetModel.products.contains(.mercuryDeposits) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return exchangeAccountProvider
            .account(for: asset)
            .map { [asset] account in
                CryptoAccountCustodialGroup(asset: asset, account: account)
            }
            .catchErrorJustReturn(CryptoAccountCustodialGroup(asset: asset))
    }

    private var custodialGroup: Single<AccountGroup> {
        .just(CryptoAccountCustodialGroup(asset: asset, account: CryptoTradingAccount(asset: asset)))
    }

    private var nonCustodialGroup: Single<AccountGroup> {
        .just(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
    }

    private var interestGroup: Single<AccountGroup> {
        guard asset.assetModel.products.contains(.interestBalance) else {
            return .just(CryptoAccountCustodialGroup(asset: asset))
        }
        return .just(CryptoAccountCustodialGroup(asset: asset, account: CryptoInterestAccount(asset: asset)))
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        let result = try? addressFactory
            .makeExternalAssetAddress(
                asset: asset,
                address: address,
                label: address,
                onTxCompleted: { _ in Completable.empty() }
            )
            .get()
        return .just(result)
    }
}
