// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import Localization
import RxCocoa
import RxRelay
import RxSwift

/// A view model for `MnemonicTextViewViewModel`
public struct MnemonicTextViewViewModel {

    public enum State: Equatable {

        case valid(value: NSAttributedString)

        case incomplete(value: NSAttributedString)

        case excess(value: NSAttributedString)

        case empty

        case invalid(value: NSAttributedString)

        init(
            input: String,
            score: MnemonicValidationScore,
            validStyle: Style = .default,
            invalidStyle: Style = .desctructive
        ) {
            switch score {
            case .valid:
                self = .valid(value: .init(
                    input.lowercased(),
                    font: validStyle.font,
                    color: validStyle.color
                )
                )
            case .incomplete:
                self = .incomplete(value: .init(
                    input.lowercased(),
                    font: validStyle.font,
                    color: validStyle.color
                )
                )
            case .excess:
                self = .excess(value: .init(
                    input.lowercased(),
                    font: invalidStyle.font,
                    color: invalidStyle.color
                ))
            case .invalid(let ranges):
                let attributed: NSMutableAttributedString = .init(
                    input.lowercased(),
                    font: validStyle.font,
                    color: validStyle.color
                )
                ranges.forEach {
                    attributed.addAttributes([
                        .font: invalidStyle.font,
                        .foregroundColor: invalidStyle.color
                    ], range: $0)
                }
                self = .invalid(value: .init(attributedString: attributed))
            case .none:
                self = .empty
            }
        }
    }

    /// A style for text
    public struct Style {
        public let color: UIColor
        public let font: UIFont

        public init(color: UIColor, font: UIFont) {
            self.color = color
            self.font = font
        }
    }

    // MARK: Properties

    /// The state of the text field
    public var state: Observable<State> {
        stateRelay.asObservable()
    }

    var borderColor: Driver<UIColor> {
        borderColorRelay.asDriver()
    }

    let accessibility: Accessibility = .id(Accessibility.Identifier.MnemonicTextView.recoveryPhrase)

    let attributedPlaceholder = NSAttributedString(
        string: LocalizationConstants.TextField.Title.recoveryPhrase,
        attributes: [.font: UIFont.main(.medium, 16.0)]
    )

    let attributedTextRelay = BehaviorRelay<NSAttributedString>(value: .init(string: ""))
    var attributedText: Driver<NSAttributedString> {
        attributedTextRelay
            .asDriver()
    }

    /// The content of the text field
    let textRelay = BehaviorRelay<String>(value: "")
    var text: Observable<String> {
        textRelay.asObservable()
    }

    /// Each input is formatted according to its nature
    public enum Input {
        /// A regular string
        case text(string: String)
    }

    let lineSpacing: CGFloat

    private let borderColorRelay = BehaviorRelay<UIColor>(value: .black)
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    private let validator: MnemonicValidating
    private let disposeBag = DisposeBag()

    public init(
        validator: MnemonicValidating,
        lineSpacing: CGFloat = 0
    ) {
        self.lineSpacing = lineSpacing
        self.validator = validator

        text
            .bindAndCatch(to: validator.valueRelay)
            .disposed(by: disposeBag)

        Observable.zip(validator.valueRelay, validator.score)
            .map { value, score -> State in
                State(input: value, score: score)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        validator.score.map(\.tintColor)
            .bindAndCatch(to: borderColorRelay)
            .disposed(by: disposeBag)

        stateRelay.map { state -> NSAttributedString in
            switch state {
            case .empty:
                return .init(string: "")
            case .valid(value: let value):
                return value
            case .incomplete(value: let value):
                return value
            case .excess(value: let value):
                return value
            case .invalid(value: let value):
                return value
            }
        }
        .bindAndCatch(to: attributedTextRelay)
        .disposed(by: disposeBag)
    }

    /// Should be called upon editing the text field
    func textViewEdited(with value: String) {
        textRelay.accept(value)
    }
}

extension MnemonicTextViewViewModel.Style {
    static let `default`: MnemonicTextViewViewModel.Style = .init(
        color: .black,
        font: UIFont.main(.medium, 16.0)
    )

    static let desctructive: MnemonicTextViewViewModel.Style = .init(
        color: .destructive,
        font: UIFont.main(.medium, 16.0)
    )
}

extension MnemonicTextViewViewModel.State {
    public static func == (lhs: MnemonicTextViewViewModel.State, rhs: MnemonicTextViewViewModel.State) -> Bool {
        switch (lhs, rhs) {
        case (.valid(let left), .valid(value: let right)):
            return left == right
        case (.invalid(let left), .invalid(let right)):
            return left == right
        case (.incomplete(let left), .incomplete(value: let right)):
            return left == right
        case (.excess(let left), .excess(value: let right)):
            return left == right
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

extension MnemonicValidationScore {
    var tintColor: UIColor {
        switch self {
        case .valid:
            return .normalPassword
        case .incomplete,
             .none:
            return .mediumBorder
        case .invalid,
             .excess:
            return .destructive
        }
    }
}
