// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public protocol BalanceServiceAPI {

    func balance(for wallet: XPub) -> Single<CryptoValue>

    func balances(for wallets: [XPub]) -> Single<CryptoValue>
}

final class BalanceService: BalanceServiceAPI {

    private let client: APIClientAPI
    private let coin: BitcoinChainCoin

    convenience init(coin: BitcoinChainCoin) {
        self.init(client: resolve(tag: coin), coin: coin)
    }

    init(client: APIClientAPI, coin: BitcoinChainCoin) {
        self.client = client
        self.coin = coin
    }

    // MARK: - BalanceServiceAPI

    func balance(for wallet: XPub) -> Single<CryptoValue> {
        balances(for: [wallet])
    }

    func balances(for wallets: [XPub]) -> Single<CryptoValue> {
        client.balances(for: wallets)
            .map { [coin] response in
                BitcoinChainBalances(response: response, coin: coin)
            }
            .map(\.total)
    }
}

private struct BitcoinChainBalances {

    let total: CryptoValue

    private let balances: [String: CryptoValue]

    init(response: BitcoinChainBalanceResponse, coin: BitcoinChainCoin) {
        let cryptoCurrency = coin.cryptoCurrency
        balances = response.compactMapValues { item -> CryptoValue? in
            CryptoValue.create(minor: "\(item.finalBalance)", currency: cryptoCurrency)
        }
        total = (try? balances
            .values
            .reduce(CryptoValue.zero(currency: cryptoCurrency), +)) ?? CryptoValue.zero(currency: cryptoCurrency)
    }
}
