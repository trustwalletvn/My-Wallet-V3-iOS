// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

extension Accessibility.Identifier {
    enum Amount {
        static let max = "Amount.useMaxButton"
        static let min = "Amount.useMinButton"
        static let warning = "Amount.warning"
        static let error = "Amount.error"
    }
}

public final class AmountTranslationPresenter: AmountViewPresenting {

    // MARK: - Types

    public struct DisplayBundle {
        public struct Events {
            public let minTappedAnalyticsEvent: AnalyticsEvent
            public let maxTappedAnalyticsEvent: AnalyticsEvent

            public init(min: AnalyticsEvent, max: AnalyticsEvent) {
                minTappedAnalyticsEvent = min
                maxTappedAnalyticsEvent = max
            }
        }

        public struct Strings {
            public let useMin: String
            public let useMax: String

            public init(useMin: String, useMax: String) {
                self.useMin = useMin
                self.useMax = useMax
            }
        }

        public struct AccessibilityIdentifiers {
            public init() {}
        }

        public let strings: Strings
        public let events: Events
        public let accessibilityIdentifiers: AccessibilityIdentifiers

        public init(
            events: Events,
            strings: Strings,
            accessibilityIdentifiers: AccessibilityIdentifiers
        ) {
            self.events = events
            self.strings = strings
            self.accessibilityIdentifiers = accessibilityIdentifiers
        }
    }

    public enum Input {
        case input(Character)
        case delete
    }

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.BuyCryptoScreen.LimitView
    private typealias AccessibilityId = Accessibility.Identifier.Amount

    // MARK: - Public Properties

    public let swapButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)

    // MARK: - Internal Properties

    var activeAmountInput: Driver<ActiveAmountInput> {
        interactor.activeInputRelay.asDriver()
    }

    var state: Driver<AmountPresenterState> {
        stateRelay.asDriver()
    }

    var swapButtonVisibility: Driver<Visibility> {
        swapButtonVisibilityRelay.asDriver()
    }

    let swapButtonTapRelay = PublishRelay<Void>()

    // MARK: - Injected

    let interactor: AmountTranslationInteractor
    let fiatPresenter: InputAmountLabelPresenter
    let cryptoPresenter: InputAmountLabelPresenter
    let displayBundle: DisplayBundle

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - Accessors

    private let stateRelay = BehaviorRelay<AmountPresenterState>(value: .showSecondaryAmountLabel)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        interactor: AmountTranslationInteractor,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        displayBundle: DisplayBundle,
        inputTypeToggleVisiblity: Visibility
    ) {
        self.displayBundle = displayBundle
        swapButtonVisibilityRelay.accept(inputTypeToggleVisiblity)
        self.interactor = interactor
        fiatPresenter = .init(interactor: interactor.fiatInteractor, currencyCodeSide: .leading)
        cryptoPresenter = .init(interactor: interactor.cryptoInteractor, currencyCodeSide: .trailing)
        self.analyticsRecorder = analyticsRecorder

        swapButtonTapRelay
            .withLatestFrom(interactor.activeInput)
            .map(\.inverted)
            .bindAndCatch(to: interactor.activeInputRelay)
            .disposed(by: disposeBag)

        Observable
            .combineLatest(
                interactor.state,
                interactor.activeInput
            )
            .map(weak: self) { (self, payload) in
                self.setupButton(by: payload.0, activeInput: payload.1)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        interactor.connect(input: input.map(\.toInteractorInput))
            .map { [weak self] state -> AmountPresenterState in
                guard let self = self else { return .empty }

                return self.setupButton(by: state, activeInput: self.interactor.activeInputRelay.value)
            }
    }

    private func setupButton(
        by state: AmountInteractorState,
        activeInput: ActiveAmountInput
    ) -> AmountPresenterState {
        switch state {
        case .empty, .inBounds:
            return .showSecondaryAmountLabel
        case .error(let message):
            let viewModel = ButtonViewModel.currencyOutOfBounds(
                with: message,
                accessibilityId: AccessibilityId.error
            )
            return .warning(viewModel)
        case .warning(let message, let action):
            let viewModel = ButtonViewModel.warning(
                with: message,
                accessibilityId: AccessibilityId.warning
            )
            viewModel.tap
                .throttle(.seconds(1))
                .emit(onNext: { _ in
                    action()
                })
                .disposed(by: disposeBag)
            return .warning(viewModel)
        case .maxLimitExceeded(let maxValue):
            /// The min/max string value can include one parameter. If it does not
            /// just show the localized string.
            var message = ""
            if displayBundle.strings.useMax.contains("%@") {
                message = String(format: displayBundle.strings.useMax, maxValue.toDisplayString(includeSymbol: true))
            } else {
                message = displayBundle.strings.useMax
            }
            let viewModel = ButtonViewModel.currencyOutOfBounds(
                with: message,
                accessibilityId: AccessibilityId.max
            )
            viewModel.tap
                .throttle(.seconds(1))
                .emit(onNext: { [maxValue, weak self] in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(event: self.displayBundle.events.maxTappedAnalyticsEvent)
                    self.interactor.set(amount: maxValue)
                })
                .disposed(by: disposeBag)
            return .warning(viewModel)
        case .underMinLimit(let minValue):
            /// The min/max string value can include one parameter. If it does not
            /// just show the localized string.
            var message = ""
            if displayBundle.strings.useMin.contains("%@") {
                message = String(format: displayBundle.strings.useMin, minValue.toDisplayString(includeSymbol: true))
            } else {
                message = displayBundle.strings.useMin
            }
            let viewModel = ButtonViewModel.currencyOutOfBounds(
                with: message,
                accessibilityId: AccessibilityId.min
            )
            viewModel.tap
                .throttle(.seconds(1))
                .emit(onNext: { [minValue, weak self] in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(event: self.displayBundle.events.minTappedAnalyticsEvent)
                    self.interactor.set(minAmount: minValue)
                })
                .disposed(by: disposeBag)
            return .warning(viewModel)
        }
    }
}

extension AmountPresenterInput {
    internal var toInteractorInput: AmountInteractorInput {
        switch self {
        case .input(let value):
            return .insert(value)
        case .delete:
            return .remove
        }
    }
}
