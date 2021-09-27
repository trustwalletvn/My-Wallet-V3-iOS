// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import RxSwift

/// `Wallet.m` needs to be injected into much of the `WalletRepository` type classes.
/// The reason is we still heavily rely on `My-Wallet-V3`. We don't want to bring this into
/// `PlatformKit` as a dependency. So, we have `Wallet.m` conform to protocols that we need
/// and inject it in as a dependency. Frequently we'll use the term `bridge` as a way of
/// describing this.
public protocol EthereumWalletAccountBridgeAPI: AnyObject {
    var wallets: Single<[EthereumWalletAccount]> { get }
}

public protocol EthereumWalletBridgeAPI: AnyObject {
    var name: Single<String> { get }
    var address: Single<EthereumAddress> { get }
    var account: Single<EthereumAssetAccount> { get }

    func memo(for transactionHash: String) -> Single<String?>
    func updateMemo(for transactionHash: String, memo: String?) -> Completable

    func recordLast(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished>

    /// Updates the Ethereum account label at the given index.
    func update(accountIndex: Int, label: String) -> Completable
}

public typealias CompleteEthereumWalletBridgeAPI =
    EthereumWalletBridgeAPI
        & EthereumWalletAccountBridgeAPI
        & MnemonicAccessAPI
        & PasswordAccessAPI
