// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

/// Regex validator. Receives a `TextRegex` and validates the value against it.
final class WordValidator: TextValidating {

    // MARK: - TextValidating Properties

    var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }

    let valueRelay = BehaviorRelay<String>(value: "")

    // MARK: - Private Properties

    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(word: String) {
        valueRelay
            .map { $0.lowercased() == word.lowercased() }
            .map { $0 ? .valid : .invalid(reason: nil) }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}
