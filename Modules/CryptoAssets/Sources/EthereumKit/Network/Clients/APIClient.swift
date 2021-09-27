// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import NetworkKit
import PlatformKit
import RxSwift

protocol TransactionPushClientAPI: AnyObject {
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse>
}

protocol TransactionClientAPI {
    var latestBlock: Single<LatestBlockResponse> { get }

    func transaction(with hash: String) -> Single<EthereumHistoricalTransactionResponse>
    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]>
}

protocol BalanceClientAPI {
    func balanceDetails(from address: String) -> Single<BalanceDetailsResponse>
}

protocol TransactionFeeClientAPI {
    func fees(cryptoCurrency: CryptoCurrency) -> Single<TransactionFeeResponse>
}

final class APIClient: TransactionPushClientAPI, TransactionClientAPI, BalanceClientAPI, TransactionFeeClientAPI {

    // MARK: - Types

    /// Potential errors
    enum ClientError: Error {

        /// Error building the request
        case buildingRequest

        /// Balance is missing for address
        case missingBalanceResponseForAddress

        /// Account is missing for
        case missingAccountResponseForAddress
    }

    /// Privately used endpoint data
    private enum Endpoint {
        static let fees: [String] = ["mempool", "fees", "eth"]
        static let base: [String] = ["eth"]
        static let pushTx: [String] = base + ["pushtx"]

        static func balance(for address: String) -> [String] {
            base + ["account", address, "balance"]
        }

        static func account(for address: String) -> [String] {
            base + ["account", address]
        }
    }

    /// Privately used endpoint data
    private enum EndpointV2 {
        private static let base: [String] = ["v2", "eth", "data"]
        private static let account: [String] = base + ["account"]

        static let latestBlock: [String] = base + ["block", "latest", "number"]

        static func transactions(for address: String) -> [String] {
            account + [address, "transactions"]
        }

        static func transaction(with hash: String) -> [String] {
            base + ["transaction", hash]
        }
    }

    // MARK: - Properties

    /// Streams the latest block
    var latestBlock: Single<LatestBlockResponse> {
        let path = EndpointV2.latestBlock
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return networkAdapter.perform(request: request)
    }

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder
    private let apiCode: String

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(),
        apiCode: APICode = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        self.apiCode = apiCode
    }

    func fees(cryptoCurrency: CryptoCurrency) -> Single<TransactionFeeResponse> {
        guard cryptoCurrency == .coin(.ethereum) || cryptoCurrency.isERC20 else {
            fatalError("Using Ethereum APIClient for incompatible CryptoCurrency")
        }
        var parameters: [URLQueryItem] = []
        if let contractAddress = cryptoCurrency.erc20ContractAddress {
            parameters.append(URLQueryItem(name: "contractAddress", value: contractAddress))
        }
        guard let request = requestBuilder.get(
            path: Endpoint.fees,
            parameters: parameters
        ) else {
            return .error(RequestBuilder.Error.buildingRequest)
        }
        return networkAdapter.perform(request: request)
    }

    /// Pushes a transaction
    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse> {
        let pushTxRequest = PushTxRequest(
            rawTx: transaction.rawTransaction,
            api_code: apiCode
        )
        let data = try? JSONEncoder().encode(pushTxRequest)
        guard let request = requestBuilder.post(
            path: Endpoint.pushTx,
            body: data,
            recordErrors: true
        ) else {
            return .error(ClientError.buildingRequest)
        }
        return networkAdapter.perform(request: request)
    }

    func transaction(with hash: String) -> Single<EthereumHistoricalTransactionResponse> {
        let path = EndpointV2.transaction(with: hash)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return networkAdapter.perform(
            request: request,
            responseType: EthereumHistoricalTransactionResponse.self
        )
    }

    /// Fetches transactions for an address - returns an array of transactions
    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]> {
        let path = EndpointV2.transactions(for: account)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return networkAdapter
            .perform(
                request: request,
                responseType: EthereumAccountTransactionsResponse.self
            )
            .map(\.transactions)
    }

    /// Fetches the balance for an address
    func balanceDetails(from address: String) -> Single<BalanceDetailsResponse> {
        let path = Endpoint.balance(for: address)
        guard let request = requestBuilder.get(path: path) else {
            return .error(ClientError.buildingRequest)
        }
        return networkAdapter.perform(request: request)
            .map { (payload: [String: BalanceDetailsResponse]) -> BalanceDetailsResponse in
                guard let details = payload[address] else {
                    throw ClientError.missingBalanceResponseForAddress
                }
                return details
            }
    }
}

extension CryptoCurrency {
    fileprivate var erc20ContractAddress: String? {
        switch self {
        case .erc20(let model):
            return model.erc20Address
        default:
            return nil
        }
    }
}
