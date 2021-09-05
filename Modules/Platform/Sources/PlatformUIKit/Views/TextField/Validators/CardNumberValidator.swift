// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxRelay
import RxSwift

public final class CardNumberValidator: TextValidating, CardTypeSource {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.TextField.Gesture

    // MARK: - Exposed Properties

    /// An observable that streams the card type
    public var validationState: Observable<TextValidationState> {
        validationStateRelay.asObservable()
    }

    /// An observable that streams the card type
    public var cardType: Observable<CardType> {
        cardTypeRelay.asObservable()
    }

    public let valueRelay = BehaviorRelay<String>(value: "")
    public let supportedCardTypesRelay = BehaviorRelay<Set<CardType>>(value: [])

    // MARK: - Private Properties

    private let cardTypeRelay = BehaviorRelay<CardType>(value: .unknown)
    private let luhnValidator = LuhnNumberValidator()
    private let validationStateRelay = BehaviorRelay<TextValidationState>(value: .invalid(reason: nil))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(supportedCardTypes: Set<CardType> = [.visa]) {
        supportedCardTypesRelay.accept(supportedCardTypes)

        valueRelay
            .map { .determineType(from: $0) }
            .bindAndCatch(to: cardTypeRelay)
            .disposed(by: disposeBag)

        let inputData = Observable
            .zip(valueRelay, cardType)

        Observable
            .combineLatest(
                inputData,
                supportedCardTypesRelay
            )
            .map(weak: self) { (self, payload) in
                let ((value, cardType), supportedCardTypes) = payload

                let isSupported: Bool
                if cardType.isKnown {
                    isSupported = supportedCardTypes.contains(cardType)
                } else {
                    isSupported = true
                }

                guard isSupported else {
                    return .invalid(reason: LocalizedString.unsupportedCardType)
                }

                guard self.isValid(value) else {
                    return .invalid(reason: LocalizedString.invalidCardNumber)
                }

                return .valid
            }
            .bindAndCatch(to: validationStateRelay)
            .disposed(by: disposeBag)
    }

    func supports(cardType: CardType) -> Bool {
        supportedCardTypesRelay.value.contains(cardType)
    }

    private func isValid(_ number: String) -> Bool {
        var number = number
        number.removeAll { $0 == " " }

        guard luhnValidator.validate(number: number) else {
            return false
        }
        for type in CardType.all {
            let predicate = NSPredicate(format: "SELF MATCHES %@", type.regex)
            if predicate.evaluate(with: number) {
                return true
            }
        }
        return false
    }
}
