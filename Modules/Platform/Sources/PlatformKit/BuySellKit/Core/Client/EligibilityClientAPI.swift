// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol EligibilityClientAPI: AnyObject {

    /// Streams a boolean value indicating whether the user can or cannot trade
    func isEligible(
        for currency: String,
        methods: [String]
    ) -> Single<EligibilityResponse>
}
