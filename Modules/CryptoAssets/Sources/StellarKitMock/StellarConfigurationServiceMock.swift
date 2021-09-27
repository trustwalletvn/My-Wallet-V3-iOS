// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import StellarKit

class StellarConfigurationServiceMock: StellarConfigurationAPI {
    var configuration: Single<StellarConfiguration> = .just(StellarConfiguration.Stellar.test)
}
