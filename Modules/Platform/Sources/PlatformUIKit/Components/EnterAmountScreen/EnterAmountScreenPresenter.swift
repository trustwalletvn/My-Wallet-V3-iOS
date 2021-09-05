// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A presenter for enter amount screen. Designed to be subclassed by Buy, Sell, Send, Swap corresponding presenters
open class EnterAmountScreenPresenter: RibBridgePresenter {

    // MARK: - Types

    /// The state of the bottom auxiliary view
    public enum BottomAuxiliaryViewModelState {

        /// A selection button - used to show dropdowns
        case selection(SelectionButtonViewModel)

        /// Max available style button with available amount for spending and use-maximum button
        case maxAvailable(SendAuxiliaryViewPresenter)

        /// Hidden - nothing to present
        case hidden
    }

    // MARK: - Properties

    public let deviceType = DevicePresenter.type
    let title: String

    public var bottomAuxiliaryViewModelState: Driver<BottomAuxiliaryViewModelState> {
        bottomAuxiliaryViewModelStateRelay.asDriver()
    }

    public let bottomAuxiliaryViewModelStateRelay = BehaviorRelay(
        value: BottomAuxiliaryViewModelState.hidden
    )

    public var continueButtonTapped: Signal<Void> {
        continueButtonViewModel.tap
    }

    // MARK: - Components (ViewModels / Presenters)

    public let topSelectionButtonViewModel: SelectionButtonViewModel

    let continueButtonViewModel: ButtonViewModel
    let amountTranslationPresenter: AmountTranslationPresenter
    let bottomAuxiliaryItemSeparatorViewModel: TitledSeparatorViewModel
    let digitPadViewModel: DigitPadViewModel

    // MARK: - Injected

    public let loader: LoadingViewPresenting
    public let alert: AlertViewPresenterAPI
    public let analyticsRecorder: AnalyticsEventRecorderAPI
    public let displayBundle: DisplayBundle
    public let inputTypeToggleVisiblity: Visibility

    private let errorRecorder: ErrorRecording
    private let interactor: EnterAmountScreenInteractor
    private let backwardsNavigation: () -> Void

    // MARK: - Accessors

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        loader: LoadingViewPresenting = resolve(),
        alert: AlertViewPresenterAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        inputTypeToggleVisibility: Visibility,
        backwardsNavigation: @escaping () -> Void,
        displayBundle: DisplayBundle,
        interactor: EnterAmountScreenInteractor
    ) {
        self.loader = loader
        self.alert = alert
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
        self.interactor = interactor
        self.backwardsNavigation = backwardsNavigation
        title = displayBundle.strings.title
        self.displayBundle = displayBundle
        inputTypeToggleVisiblity = inputTypeToggleVisibility
        bottomAuxiliaryItemSeparatorViewModel = TitledSeparatorViewModel(
            title: displayBundle.strings.bottomAuxiliaryItemSeparatorTitle,
            separatorColor: displayBundle.colors.bottomAuxiliaryItemSeparator,
            accessibilityId: displayBundle.accessibilityIdentifiers.bottomAuxiliaryItemSeparatorTitle
        )
        amountTranslationPresenter = AmountTranslationPresenter(
            interactor: interactor.amountTranslationInteractor,
            displayBundle: displayBundle.amountDisplayBundle,
            inputTypeToggleVisiblity: inputTypeToggleVisibility
        )
        digitPadViewModel = EnterAmountScreenPresenter.digitPadViewModel()
        continueButtonViewModel = .primary(with: displayBundle.strings.ctaButton)
        topSelectionButtonViewModel = SelectionButtonViewModel(showSeparator: true)
        super.init(interactable: interactor)
    }

    // MARK: - Exposed methods

    override open func viewDidLoad() {
        super.viewDidLoad()

        interactor.hasValidState
            .bindAndCatch(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        interactor
            .selectedCurrencyType
            .map(\.logoResource)
            .map { logoResource in
                .image(
                    .init(
                        image: logoResource,
                        background: .clear,
                        offset: 0,
                        cornerRadius: .round,
                        size: .init(edge: 32)
                    )
                )
            }
            .bindAndCatch(to: topSelectionButtonViewModel.leadingContentTypeRelay)
            .disposed(by: disposeBag)

        interactor.selectedCurrencyType
            .map(\.name)
            .bindAndCatch(to: topSelectionButtonViewModel.titleRelay)
            .disposed(by: disposeBag)

        interactor.selectedCurrencyType
            .map { .init(id: $0.displayCode, label: $0.name) }
            .bindAndCatch(to: topSelectionButtonViewModel.accessibilityContentRelay)
            .disposed(by: disposeBag)

        let displayBundle = self.displayBundle

        interactor.selectedCurrencyType
            .map { displayBundle.events.sourceAccountChanged($0.code) }
            .subscribe(onNext: analyticsRecorder.record(event:))
            .disposed(by: disposeBag)

        topSelectionButtonViewModel.trailingContentRelay.accept(
            .image(
                ImageViewContent(
                    imageResource: .local(name: "icon-disclosure-down-small", bundle: .platformUIKit)
                )
            )
        )

        interactor.didLoad()
    }

    override open func viewWillAppear() {
        super.viewWillAppear()
        analyticsRecorder.record(events: displayBundle.events.didAppear)
    }

    func previous() {
        backwardsNavigation()
    }

    public func handle(_ error: Error) {
        Logger.shared.error(error)
        errorRecorder.error(error)
        analyticsRecorder.record(event: displayBundle.events.confirmFailure)
        loader.hide()
        alert.notify(
            content: AlertViewContent(
                title: LocalizationConstants.Errors.genericError,
                message: String(describing: error)
            ),
            in: nil
        )
    }

    private static func digitPadViewModel() -> DigitPadViewModel {
        let highlightColor = Color.black.withAlphaComponent(0.08)
        let model = DigitPadButtonViewModel(
            content: .label(text: MoneyValueInputScanner.Constant.decimalSeparator, tint: .titleText),
            background: .init(highlightColor: highlightColor)
        )
        return DigitPadViewModel(
            padType: .number,
            customButtonViewModel: model,
            contentTint: .titleText,
            buttonHighlightColor: highlightColor
        )
    }
}
