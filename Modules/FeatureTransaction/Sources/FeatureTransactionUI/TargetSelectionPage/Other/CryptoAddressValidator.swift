// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class CryptoAddressValidator: TextValidating {
    var validationState: Observable<TextValidationState> {
        validationStateRelay
            .asObservable()
    }

    /// NOTE: This is not used here as validation is injected
    /// by the `TargetSelectionPageModel`.
    let valueRelay = BehaviorRelay<String>(value: "")

    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let model: TargetSelectionPageModel
    private let disposeBag = DisposeBag()

    init(model: TargetSelectionPageModel) {
        self.model = model

        model
            .state
            .map(\.inputValidated)
            .compactMap(\.textInput)
            .map { validation -> TextValidationState in
                switch validation {
                case .invalid,
                     .inactive:
                    return .invalid(reason: "Invalid Address")
                case .valid:
                    return .valid
                }
            }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}
