// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class KYCStateSelectionInteractor {

    private let client: KYCClientAPI

    init(client: KYCClientAPI = resolve()) {
        self.client = client
    }

    func fetchState(for country: CountryData) -> Single<[KYCState]> {
        client.listOfStates(in: country.code)
            .asSingle()
    }
}
