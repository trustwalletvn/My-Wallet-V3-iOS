// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CurrencyServiceAPI: AnyObject {

    /// An `Observable` that streams `Currency` values
    var currencyObservable: Observable<Currency> { get }

    /// A `Single` that streams `Currency` values
    var currency: Single<Currency> { get }
}
