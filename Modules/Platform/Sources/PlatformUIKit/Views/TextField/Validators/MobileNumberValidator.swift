// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PhoneNumberKit

import RxRelay
import RxSwift

/// Mobile number validator. Uses `PhoneNumberKit`
/// to validate the users phone number entry
final class MobileNumberValidator: TextValidating {

    // MARK: - TextValidating Properties

    let valueRelay = BehaviorRelay<String>(value: "")
    var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }

    // MARK: - Private Properties

    private let phoneKit = PhoneNumberKit()

    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init() {
        valueRelay
            .flatMap(weak: self) { (self, value) -> Observable<Bool> in
                self.validate(value: value).asObservable()
            }
            .map { $0 ? .valid : .invalid(reason: nil) }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }

    private func validate(value: String) -> Single<Bool> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            if value.isEmpty {
                observer(.success(false))
            } else {
                do {
                    _ = try self.phoneKit.parse(value)
                    observer(.success(true))
                } catch {
                    observer(.success(false))
                }
            }
            return Disposables.create()
        }
    }
}
