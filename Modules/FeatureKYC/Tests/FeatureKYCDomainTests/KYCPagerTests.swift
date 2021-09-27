// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCDomain
import PlatformKit
@testable import PlatformKitMock
import XCTest

class KYCPagerTests: XCTestCase {

    private var pager: KYCPagerAPI!
    private var dataRepository: DataRepositoryMock!

    private let response = KYC.UserTiers(
        tiers: [
            KYC.UserTier(tier: .tier1, state: .verified),
            KYC.UserTier(tier: .tier2, state: .pending)
        ]
    )

    override func setUp() {
        super.setUp()
        dataRepository = DataRepositoryMock()
        pager = KYCPager(dataRepository: dataRepository, tier: .tier1, tiersResponse: response)
    }
}
