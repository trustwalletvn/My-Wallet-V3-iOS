// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import DIKit
import FeatureSettingsDomain
import NetworkKit
import PlatformKit
import RxSwift

protocol ExchangeClientAPI {
    typealias LinkID = String

    var linkID: Single<LinkID> { get }

    func linkToExistingExchangeUser(linkID: LinkID) -> Completable
    func syncDepositAddress(accounts: [CryptoReceiveAddress]) -> Completable
}

final class ExchangeClient: ExchangeClientAPI {

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI
    private let appSettings: BlockchainSettings.App

    init(
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail),
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        settings: BlockchainSettings.App = resolve()
    ) {
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
        appSettings = settings
    }

    var linkID: Single<LinkID> {
        let fallback = fetchLinkIDPayload()
            .flatMap(weak: self) { _, payload -> Single<LinkID> in
                guard let linkID = payload["linkId"] else {
                    return Single.error(ExchangeLinkingAPIError.noLinkID)
                }

                return Single.just(linkID)
            }
        return existingUserLinkIdentifier().ifEmpty(switchTo: fallback)
    }

    func syncDepositAddress(accounts: [CryptoReceiveAddress]) -> Completable {
        let depositAddresses = accounts.reduce(into: [String: String]()) { result, receiveAddress in
            result[receiveAddress.asset.code] = receiveAddress.address
        }
        let payload = ["addresses": depositAddresses]
        let request = requestBuilder.post(
            path: ["users", "deposit", "addresses"],
            body: try? JSONEncoder().encode(payload),
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    func linkToExistingExchangeUser(linkID: LinkID) -> Completable {
        let payload = ["linkId": linkID]
        let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl)!
        let components = ["users", "link-account", "existing"]
        let endpoint = URL.endpoint(apiURL, pathComponents: components)!
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: try? JSONEncoder().encode(payload),
            authenticated: true,
            contentType: .json
        )
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    func fetchLinkIDPayload() -> Single<[String: String]> {
        let apiURL = URL(string: BlockchainAPI.shared.retailCoreUrl)!
        let components = ["users", "link-account", "create", "start"]
        let endpoint = URL.endpoint(apiURL, pathComponents: components)!
        let request = NetworkRequest(
            endpoint: endpoint,
            method: .put,
            body: nil,
            authenticated: true,
            contentType: .json
        )
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    private func existingUserLinkIdentifier() -> Maybe<LinkID> {
        if let identifier = appSettings.exchangeLinkIdentifier {
            return Maybe.just(identifier)
        } else {
            return Maybe.empty()
        }
    }
}
