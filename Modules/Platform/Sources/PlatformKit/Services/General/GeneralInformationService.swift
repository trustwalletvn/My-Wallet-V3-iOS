// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol GeneralInformationServiceAPI {

    var countries: Single<[CountryData]> { get }
}

final class GeneralInformationService: GeneralInformationServiceAPI {

    // MARK: - Exposed

    /// Provides the countries fetched from remote
    var countries: Single<[CountryData]> {
        countriesCachedValue.valueSingle
    }

    private let client: GeneralInformationClientAPI
    private let countriesCachedValue: CachedValue<[CountryData]>

    init(client: GeneralInformationClientAPI = resolve()) {
        self.client = client

        countriesCachedValue = .init(
            configuration: .init(
                refreshType: .periodic(seconds: 60 * 60)
            )
        )

        countriesCachedValue
            .setFetch(weak: self) { (self) in
                self.client.countries
                    .map {
                        $0.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    }
            }
    }
}
