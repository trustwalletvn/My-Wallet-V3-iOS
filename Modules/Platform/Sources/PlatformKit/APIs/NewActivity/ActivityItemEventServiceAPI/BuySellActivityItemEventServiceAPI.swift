// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol BuySellActivityItemEventServiceAPI: AnyObject {
    func buySellActivityEvents(cryptoCurrency: CryptoCurrency) -> Single<[BuySellActivityItemEvent]>
}
