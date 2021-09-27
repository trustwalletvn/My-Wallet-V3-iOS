// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

public protocol GeneralInformationClientAPI: AnyObject {
    var countries: AnyPublisher<[CountryData], NabuNetworkError> { get }
}

final class GeneralInformationClient: GeneralInformationClientAPI {

    // MARK: - Types

    private enum Path {
        static let countries = ["countries"]
    }

    // MARK: - Properties

    /// Requests a session token for the wallet, if not available already
    var countries: AnyPublisher<[CountryData], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.countries
        )!
        return networkAdapter.perform(
            request: request,
            responseType: [CountryData].self
        )
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
}
