// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import NetworkKit
import PlatformKit
import RxSwift

enum APIClientError: Error {
    case unknown
}

protocol APIClientAPI {

    func multiAddress(for wallets: [XPub]) -> Single<BitcoinCashMultiAddressResponse>
    func balances(for wallets: [XPub]) -> Single<BitcoinCashBalanceResponse>
}

final class APIClient: APIClientAPI {

    private let client: BitcoinChainKit.APIClientAPI

    // MARK: - Init

    init(client: BitcoinChainKit.APIClientAPI = resolve(tag: BitcoinChainCoin.bitcoinCash)) {
        self.client = client
    }

    // MARK: - APIClientAPI

    func multiAddress(for wallets: [XPub]) -> Single<BitcoinCashMultiAddressResponse> {
        client.multiAddress(for: wallets)
    }

    func balances(for wallets: [XPub]) -> Single<BitcoinCashBalanceResponse> {
        client.balances(for: wallets)
    }
}
