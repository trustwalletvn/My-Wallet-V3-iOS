// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift

public protocol ERC20AccountDetailsServiceAPI {
    func accountDetails(cryptoCurrency: CryptoCurrency) -> Single<ERC20AssetAccountDetails>
}

final class ERC20AccountDetailsService: ERC20AccountDetailsServiceAPI {

    private let bridge: EthereumWalletBridgeAPI
    private let service: ERC20BalanceServiceAPI

    init(
        with bridge: EthereumWalletBridgeAPI = resolve(),
        service: ERC20BalanceServiceAPI = resolve()
    ) {
        self.bridge = bridge
        self.service = service
    }

    func accountDetails(cryptoCurrency: CryptoCurrency) -> Single<ERC20AssetAccountDetails> {
        bridge.address
            .flatMap(weak: self) { (self, address) -> Single<(address: EthereumAddress, balance: CryptoValue)> in
                self.service.balance(for: address, cryptoCurrency: cryptoCurrency)
                    .map { (address, $0) }
                    .asSingle()
            }
            .map { (address: EthereumAddress, balance: CryptoValue) -> ERC20AssetAccountDetails in
                ERC20AssetAccountDetails(
                    account: ERC20AssetAccount(
                        accountAddress: address.publicKey,
                        name: "My \(cryptoCurrency.name) Wallet"
                    ),
                    balance: balance
                )
            }
    }
}
