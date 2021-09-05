// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxSwift
import ToolKit

public protocol CryptoAsset: Asset {
    var asset: CryptoCurrency { get }
    var defaultAccount: Single<SingleAccount> { get }
    var canTransactToCustodial: Single<Bool> { get }

    // MARK: - Services

    var kycTiersService: KYCTiersServiceAPI { get }
}

extension CryptoAsset {
    public var canTransactToCustodial: Single<Bool> {
        kycTiersService.tiers
            .map { tiers in
                tiers.isTier1Approved || tiers.isTier2Approved
            }
            .catchErrorJustReturn(false)
    }

    public func initialize() -> Completable {
        .empty()
    }

    /// Forces wallets with the previous legacy label to the new default label.
    public func upgradeLegacyLabels(accounts: [BlockchainAccount]) -> Completable {
        Single.just(accounts)
            // Optional cast each element in the array to `CryptoNonCustodialAccount`.
            .map { $0.compactMap { $0 as? CryptoNonCustodialAccount } }
            // Filter in elements that need `labelNeedsForcedUpdate`.
            .map { $0.filter(\.labelNeedsForcedUpdate) }
            // Map to infallible Completable jobs.
            .map { accounts -> [Completable] in
                accounts.map {
                    // Updates this account label with new default.
                    $0.updateLabel($0.newForcedUpdateLabel)
                        .onErrorComplete()
                }
            }
            // Concat.
            .flatMapCompletable { completables -> Completable in
                .concat(completables)
            }
    }

    /// Possible transaction targets this `Asset` has for a transaction initiating from the given `SingleAccount`.
    public func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]> {
        guard let crypto = account as? CryptoAccount else {
            fatalError("Expected a CryptoAccount: \(account).")
        }
        guard crypto.asset == asset else {
            fatalError("Expected asset to be the same.")
        }
        switch crypto {
        case is CryptoTradingAccount,
             is CryptoNonCustodialAccount:
            return canTransactToCustodial
                .flatMap(weak: self) { (self, canTransactToCustodial) -> Single<AccountGroup> in
                    self.accountGroup(filter: canTransactToCustodial ? .all : .nonCustodial)
                }
                .map(\.accounts)
                .mapFilter(excluding: crypto.identifier)
        default:
            unimplemented()
        }
    }
}

extension CryptoNonCustodialAccount {

    /// Replaces the part of this wallet label that matches the previous default wallet label with the new default label.
    /// To be used only during the forced wallet label update.
    fileprivate var newForcedUpdateLabel: String {
        guard let legacyLabel = asset.legacyLabel else {
            return label
        }
        return label.replacingOccurrences(of: legacyLabel, with: asset.defaultWalletName)
    }

    /// If this account label need to be updated to the new default label.
    /// To be used only during the forced wallet label update.
    fileprivate var labelNeedsForcedUpdate: Bool {
        guard let legacyLabel = asset.legacyLabel else {
            return false
        }
        return label.contains(legacyLabel)
    }
}

extension CryptoCurrency {

    /// The default label for this asset, it may not be a localized string.
    /// To be used only during the forced wallet label update.
    fileprivate var legacyLabel: String? {
        switch self {
        case .coin(.bitcoin):
            return LocalizationConstants.Account.legacyMyBitcoinWallet
        case .coin(.bitcoinCash):
            // Legacy BCH label is not localized.
            return "My Bitcoin Cash Wallet"
        case .coin(.ethereum):
            // Legacy ETH label is not localized.
            return "My Ether Wallet"
        case .coin(.stellar):
            // Legacy XLM label is not localized.
            return "My Stellar Wallet"
        default:
            // Any other existing or future asset does not need forced wallet name upgrade.
            return nil
        }
    }
}
