// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit
import RxSwift
import ToolKit

// TODO: Currently does not support crypto -> crypto / fiat to crypto.
// TODO: Fix the prices series API: it's barely understandable with String params.
public protocol PriceClientAPI {

    /// Fetches the prices of the given `Currency` from the specified timestamp
    /// - parameter baseCurrencyCode: The currency code of which price will be fetched.
    /// - parameter quoteCurrencyCode: The currency code in which the price will be represented.
    /// - parameter start: The Unix Time timestamp of required moment.
    /// - parameter scale: The required time scale.
    /// - returns:A `RxSwift.Single` streaming an array of `PriceQuoteAtTimeResponse` on success, or a `NetworkError` on failure.
    func priceSeries(of baseCurrencyCode: String, in quoteCurrencyCode: String, start: String, scale: String) -> Single<[PriceQuoteAtTimeResponse]>

    /// Fetches the price of the given `Currency` in the specific timestamp
    /// - parameter baseCurrencyCode: The currency code of which price will be fetched.
    /// - parameter quoteCurrencyCode: The currency code in which the price will be represented.
    /// - parameter timestamp: The Unix Time timestamp of required moment. A nil value gets the current price.
    /// - returns:A `RxSwift.Single` streaming a `PriceQuoteAtTimeResponse` on success, or a `NetworkError` on failure.
    func price(for baseCurrencyCode: String, in quoteCurrencyCode: String, at timestamp: UInt64?) -> Single<PriceQuoteAtTimeResponse>

    /// Fetches the prices of the given `Currency` from the specified timestamp
    /// - parameter baseCurrencyCode: The currency code of which price will be fetched.
    /// - parameter quoteCurrencyCode: The currency code in which the price will be represented.
    /// - parameter start: The Unix Time timestamp of required moment.
    /// - parameter scale: The required time scale.
    /// - returns:A `Combine.Publisher` streaming an array of `PriceQuoteAtTimeResponse` on success, or a `NetworkError` on failure.
    func priceSeriesPublisher(
        of baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[PriceQuoteAtTimeResponse], NetworkError>

    /// Fetches the price of the given `Currency` in the specific timestamp
    /// - parameter baseCurrencyCode: The currency code of which price will be fetched.
    /// - parameter quoteCurrencyCode: The currency code in which the price will be represented.
    /// - parameter timestamp: The Unix Time timestamp of required moment. A nil value gets the current price.
    /// - returns:A `Combine.Publisher` streaming a `PriceQuoteAtTimeResponse` on success, or a `NetworkError` on failure.
    func pricePublisher(
        for baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        at timestamp: UInt64?
    ) -> AnyPublisher<PriceQuoteAtTimeResponse, NetworkError>
}

/// Class for interacting with Blockchain's Service-Price backend service.
///
/// This service is in charge of all price related data (e.g. crypto to fiat prices, etc.)
///
/// API Spec https://api.blockchain.com/price/specs
final class PriceClient: PriceClientAPI {

    // MARK: - Types

    private enum Endpoint {
        static func priceSeries(base: String, quote: String, start: String, scale: String) -> (path: [String], query: [URLQueryItem]) {
            (
                path: ["price", "index-series"],
                query: [
                    URLQueryItem(name: "base", value: base),
                    URLQueryItem(name: "quote", value: quote),
                    URLQueryItem(name: "start", value: start),
                    URLQueryItem(name: "scale", value: scale)
                ]
            )
        }

        static func price(
            at timestamp: UInt64?,
            baseCurrencyCode: String,
            quoteCurrencyCode: String
        ) -> (path: [String], query: [URLQueryItem]) {
            var items = [
                URLQueryItem(name: "base", value: baseCurrencyCode),
                URLQueryItem(name: "quote", value: quoteCurrencyCode)
            ]
            if let timestamp = timestamp {
                items.append(URLQueryItem(name: "time", value: "\(timestamp)"))
            }
            return (path: ["price", "index"], query: items)
        }
    }

    // MARK: - Private properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    private let singlePriceQuoteCache: Cache<NetworkRequest, PriceQuoteAtTimeResponse>
    private let singlePriceInFlightRequestsCache: Cache<NetworkRequest, AnyPublisher<PriceQuoteAtTimeResponse, NetworkError>>

    // MARK: - Init

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(),
        cacheEntriesLifetime: TimeInterval = 30
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
        singlePriceQuoteCache = Cache(entryLifetime: cacheEntriesLifetime)
        singlePriceInFlightRequestsCache = Cache()
    }

    // MARK: - APIClientAPI

    func priceSeries(
        of baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        start: String,
        scale: String
    ) -> Single<[PriceQuoteAtTimeResponse]> {
        priceSeriesPublisher(of: baseCurrencyCode, in: quoteCurrencyCode, start: start, scale: scale)
            .asObservable()
            .asSingle()
    }

    func price(
        for baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        at timestamp: UInt64?
    ) -> Single<PriceQuoteAtTimeResponse> {
        pricePublisher(for: baseCurrencyCode, in: quoteCurrencyCode, at: timestamp)
            .asObservable()
            .asSingle()
    }

    // MARK: Combine API

    func priceSeriesPublisher(
        of baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        start: String,
        scale: String
    ) -> AnyPublisher<[PriceQuoteAtTimeResponse], NetworkError> {
        let data = Endpoint.priceSeries(
            base: baseCurrencyCode,
            quote: quoteCurrencyCode,
            start: start,
            scale: scale
        )
        let request = requestBuilder.get(
            path: data.path,
            parameters: data.query
        )!
        return networkAdapter.perform(request: request)
    }

    func pricePublisher(
        for baseCurrencyCode: String,
        in quoteCurrencyCode: String,
        at timestamp: UInt64?
    ) -> AnyPublisher<PriceQuoteAtTimeResponse, NetworkError> {
        let data = Endpoint.price(
            at: timestamp,
            baseCurrencyCode: baseCurrencyCode,
            quoteCurrencyCode: quoteCurrencyCode
        )
        let request = requestBuilder.get(
            path: data.path,
            parameters: data.query
        )!

        // return immediately an in-flight request, if available
        if let cachedPublisher = singlePriceInFlightRequestsCache.value(forKey: request) {
            Logger.shared.debug("⚠️ Duplicate request fired: \(request)")
            return cachedPublisher
        }

        // return immediately a value publisher is there's a cached API response available
        if let cachedValue = singlePriceQuoteCache.value(forKey: request) {
            return .just(cachedValue)
        }

        // No cache optimization was hit. Perform the request.
        let responsePublisher: AnyPublisher<PriceQuoteAtTimeResponse, NetworkError> = networkAdapter.perform(request: request)
            .retry(1)
            .share(replay: 1)
            .handleEvents(
                receiveOutput: { [weak self] result in
                    self?.singlePriceQuoteCache.set(result, forKey: request)
                },
                receiveCompletion: { [weak self] _ in
                    self?.singlePriceInFlightRequestsCache.removeValue(forKey: request)
                },
                receiveCancel: { [weak self] in
                    self?.singlePriceInFlightRequestsCache.removeValue(forKey: request)
                }
            )
            .eraseToAnyPublisher()

        // And cache it while in-flight
        singlePriceInFlightRequestsCache.set(responsePublisher, forKey: request)

        return responsePublisher
    }
}
