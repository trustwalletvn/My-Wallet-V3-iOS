// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

/// A validator that is always valid
final class AlwaysValidValidator: TextValidating {

    // MARK: - TextValidating Properties

    let valueRelay = BehaviorRelay<String>(value: "")
    var validationState: Observable<TextValidationState> {
        .just(.valid)
    }
}
