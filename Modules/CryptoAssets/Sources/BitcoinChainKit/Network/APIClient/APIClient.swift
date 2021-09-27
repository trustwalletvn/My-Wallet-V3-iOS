// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import PlatformKit
import RxSwift

public protocol APIClientAPI {

    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(for wallets: [XPub]) -> Single<BitcoinChainMultiAddressResponse<T>>
    func balances(for wallets: [XPub]) -> Single<BitcoinChainBalanceResponse>
    func unspentOutputs(for wallets: [XPub]) -> Single<UnspentOutputsResponse>
}

extension DerivationType {
    fileprivate var activeParameter: String {
        switch self {
        case .legacy:
            return "active"
        case .bech32:
            return "activeBech32"
        }
    }
}

final class APIClient: APIClientAPI {

    private struct Endpoint {
        var multiaddress: [String] {
            base + ["multiaddr"]
        }

        var balance: [String] {
            base + ["balance"]
        }

        var unspent: [String] {
            base + ["unspent"]
        }

        let base: [String]

        init(coin: BitcoinChainCoin) {
            base = [coin.rawValue.lowercased()]
        }
    }

    private enum Parameter {
        static func active(wallets: [XPub]) -> [URLQueryItem] {
            wallets
                .reduce(into: [DerivationType: [String]]()) { result, wallet in
                    var list = result[wallet.derivationType] ?? []
                    list.append(wallet.address)
                    result[wallet.derivationType] = list
                }
                .map { type, addresses -> URLQueryItem in
                    URLQueryItem(
                        name: type.activeParameter,
                        value: addresses.joined(separator: "|")
                    )
                }
        }
    }

    private let coin: BitcoinChainCoin
    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let endpoint: Endpoint

    // MARK: - Init

    init(
        coin: BitcoinChainCoin,
        requestBuilder: RequestBuilder = resolve(),
        networkAdapter: NetworkAdapterAPI = resolve()
    ) {
        self.coin = coin
        self.requestBuilder = requestBuilder
        endpoint = Endpoint(coin: coin)
        self.networkAdapter = networkAdapter
    }

    // MARK: - APIClientAPI

    func multiAddress<T: BitcoinChainHistoricalTransactionResponse>(for wallets: [XPub]) -> Single<BitcoinChainMultiAddressResponse<T>> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.get(
            path: endpoint.multiaddress,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }

    func balances(for wallets: [XPub]) -> Single<BitcoinChainBalanceResponse> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.get(
            path: endpoint.balance,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }

    func unspentOutputs(for wallets: [XPub]) -> Single<UnspentOutputsResponse> {
        let parameters = Parameter.active(wallets: wallets)
        let request = requestBuilder.post(
            path: endpoint.unspent,
            parameters: parameters,
            recordErrors: true
        )!
        return networkAdapter.perform(request: request)
    }
}
