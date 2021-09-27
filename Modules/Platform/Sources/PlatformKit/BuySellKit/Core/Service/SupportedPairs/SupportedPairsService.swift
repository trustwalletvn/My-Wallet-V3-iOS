// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift

public protocol SupportedPairsServiceAPI: AnyObject {

    /// Fetches `pairs` using the specified filter
    func fetchPairs(for option: SupportedPairsFilterOption) -> Single<SupportedPairs>
}

final class SupportedPairsService: SupportedPairsServiceAPI {

    // MARK: - Injected

    private let client: SupportedPairsClientAPI

    // MARK: - Setup

    init(client: SupportedPairsClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - SupportedPairsServiceAPI

    func fetchPairs(for option: SupportedPairsFilterOption) -> Single<SupportedPairs> {
        client.supportedPairs(with: option)
            .asSingle()
            .map { SupportedPairs(response: $0, filterOption: option) }
    }
}
