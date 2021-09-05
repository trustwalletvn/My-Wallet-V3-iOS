// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardChargeClientAPI: AnyObject {
    func chargeCard(by id: String) -> Completable
}
