// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A view model that represents a password text field
public final class ValidationTextFieldViewModel: TextFieldViewModel {

    // MARK: - Properties

    /// Visibility of the accessoryView
    var accessoryVisibility: Driver<Visibility> {
        visibilityRelay
            .asDriver()
            .distinctUntilChanged()
    }

    private let visibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        with type: TextFieldType,
        validator: TextValidating,
        accessibilitySuffix: String? = nil,
        formatter: TextFormatting = TextFormatterFactory.alwaysCorrect,
        textMatcher: CollectionTextMatchValidator? = nil,
        messageRecorder: MessageRecording
    ) {
        super.init(
            with: type,
            accessibilitySuffix: accessibilitySuffix,
            validator: validator,
            formatter: formatter,
            textMatcher: textMatcher,
            messageRecorder: messageRecorder
        )

        Observable
            .combineLatest(
                validator.isValid,
                validator.valueRelay
            )
            .map { (isValid: $0.0, value: $0.1) }
            .map {
                guard !$0.value.isEmpty else { return .hidden }
                return $0.isValid ? .hidden : .visible
            }
            .bindAndCatch(to: visibilityRelay)
            .disposed(by: disposeBag)
    }
}
