// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public final class CVVToCreditCardMatchValidator: TextMatchValidatorAPI {

    // MARK: - Exposed Properties

    /// An observable that streams the validation state for the streams
    public var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }

    // MARK: - Accessors

    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .valid)
    private let disposeBag = DisposeBag()

    public init(cvvTextSource: TextSource, cardTypeSource: CardTypeSource, invalidReason: String) {
        Observable
            .combineLatest(cvvTextSource.valueRelay, cardTypeSource.cardType)
            .map { (payload: (cvv: String, cardType: CardType)) in
                guard payload.cardType.isKnown else { return true }
                return payload.cvv.count == payload.cardType.cvvLength
            }
            .map { $0 ? .valid : .invalid(reason: invalidReason) }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }
}
