// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift

public protocol GeneralInformationClientAPI: AnyObject {
    var countries: Single<[CountryData]> { get }
}

final class GeneralInformationClient: GeneralInformationClientAPI {

    // MARK: - Types

    private enum Path {
        static let countries = ["countries"]
    }

    // MARK: - Properties

    /// Requests a session token for the wallet, if not available already
    var countries: Single<[CountryData]> {
        let request = requestBuilder.get(
            path: Path.countries
        )!
        return networkAdapter.perform(
            request: request,
            responseType: [CountryData].self,
            errorResponseType: NabuNetworkError.self
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
