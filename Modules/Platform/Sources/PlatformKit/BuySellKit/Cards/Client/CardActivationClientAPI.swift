// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardActivationClientAPI: AnyObject {
    func activateCard(
        by id: String,
        url: String
    ) -> Single<ActivateCardResponse.Partner>
}
