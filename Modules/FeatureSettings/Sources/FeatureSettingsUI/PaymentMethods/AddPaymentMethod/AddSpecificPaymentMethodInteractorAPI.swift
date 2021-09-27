// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol AddSpecificPaymentMethodInteractorAPI: AnyObject {
    var isAbleToAddNew: Observable<Bool> { get }
}
