// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardListClientAPI: AnyObject {
    var cardList: Single<[CardPayload]> { get }
}
