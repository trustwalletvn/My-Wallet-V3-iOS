// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol TextMatchValidatorAPI: AnyObject {
    var validationState: Observable<TextValidationState> { get }
}
