// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol SuggestedAmountsClientAPI: AnyObject {
    func suggestedAmounts(for currency: FiatCurrency) -> Single<SuggestedAmountsResponse>
}
