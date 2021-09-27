// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class EthereumActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel]

    var cells: [DetailsScreen.CellType] = []

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let interactor: EthereumActivityDetailsInteractor
    private let event: TransactionalActivityItemEvent
    private let router: ActivityRouterAPI
    private let disposeBag: DisposeBag = .init()
    private let alertViewPresenter: AlertViewPresenterAPI
    private let loadingViewPresenter: LoadingViewPresenting

    // MARK: Private Properties (Model Relay)

    private let itemRelay: BehaviorRelay<EthereumActivityDetailsViewModel?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (TextFieldViewModel)

    private let noteModel: TextFieldViewModel

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let amountPresenter: LineItemCellPresenting
    private let valuePresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let gasForPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()
    private let confirmingBadge: DefaultBadgeAssetPresenter = .init()
    private let badgeCircleModel: BadgeCircleViewModel = .init()

    // MARK: Private Properties (Explorer Button)

    private let explorerButton: ButtonViewModel

    // MARK: - Init

    init(
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        event: TransactionalActivityItemEvent,
        router: ActivityRouterAPI,
        interactor: EthereumActivityDetailsInteractor = .init(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        messageRecorder: MessageRecording = resolve()
    ) {
        precondition(event.currency == .coin(.ethereum), "Using EthereumActivityDetailsPresenter with \(event.currency) event.")
        self.alertViewPresenter = alertViewPresenter
        self.loadingViewPresenter = loadingViewPresenter
        self.router = router
        self.event = event
        self.interactor = interactor
        explorerButton = .secondary(with: LocalizedString.Button.viewOnExplorer)
        buttons = [explorerButton]
        dateCreatedPresenter = TransactionalLineItem.date().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        amountPresenter = TransactionalLineItem.amount().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        valuePresenter = TransactionalLineItem.value().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        feePresenter = TransactionalLineItem.fee().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        fromPresenter = TransactionalLineItem.from().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        toPresenter = TransactionalLineItem.to().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        gasForPresenter = TransactionalLineItem.gasFor().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )
        noteModel = TextFieldViewModel(
            with: .description,
            validator: TextValidationFactory.General.alwaysValid,
            messageRecorder: messageRecorder
        )
        bindAll(event: event)
    }

    func viewDidLoad() {
        interactor
            .details(identifier: event.identifier, createdAt: event.creationDate)
            .subscribe(
                onNext: { [weak self] model in
                    self?.itemRelay.accept(model)
                },
                onError: { [weak self] _ in
                    self?.alertViewPresenter.error(in: nil, action: nil)
                }
            )
            .disposed(by: disposeBag)
    }

    private func baseCells(isGas: Bool) -> [DetailsScreen.CellType] {
        [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(amountPresenter),
            .separator,
            .lineItem(valuePresenter),
            .separator,
            .lineItem(isGas ? gasForPresenter : feePresenter),
            .separator,
            .lineItem(fromPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .textField(noteModel)
        ]
    }

    func bindAll(event: TransactionalActivityItemEvent) {
        explorerButton
            .tapRelay
            .bind { [weak self] in
                self?.router.showBlockchainExplorer(for: event)
            }
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.isGas ?? false }
            .bindAndCatch(weak: self) { (self, isGas) in
                self.cells = self.baseCells(isGas: isGas)
                self.reloadRelay.accept(())
            }
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.factor }
            .bindAndCatch(to: badgeCircleModel.fillRatioRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.title }
            .distinctUntilChanged()
            .map(weak: self) { (self, confirmation) in
                .loaded(next: .init(type: .progress(self.badgeCircleModel), description: confirmation))
            }
            .bindAndCatch(to: confirmingBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.needConfirmation }
            .distinctUntilChanged()
            .map(weak: self) { (self, needConfirmation) in
                needConfirmation ? [self.statusBadge, self.confirmingBadge] : [self.statusBadge]
            }
            .bindAndCatch(to: badgesModel.badgesRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.amounts.isGas }
            .distinctUntilChanged()
            .map {
                switch (event.type, $0) {
                case (.send, true):
                    return LocalizedString.Title.gas
                case (.send, _):
                    return LocalizedString.Title.send
                case (.receive, _):
                    return LocalizedString.Title.receive
                }
            }
            .map { Screen.Style.TitleView.text(value: $0) }
            .bindAndCatch(to: titleViewRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.isGas == true ? $0?.amounts.fee.cryptoAmount : $0?.amounts.trade.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: cryptoAmountLabelPresenter.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.dateCreated }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: dateCreatedPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.isGas == true ? $0?.amounts.fee.amount : $0?.amounts.trade.amount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: amountPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.isGas == true ? $0?.amounts.fee.value : $0?.amounts.trade.value }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: valuePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.from }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: fromPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.to }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: toPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.gasFor?.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: gasForPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.confirmation.statusBadge }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: statusBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amounts.fee.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: feePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.memo ?? "" }
            .bindAndCatch(to: noteModel.originalTextRelay)
            .disposed(by: disposeBag)

        noteModel
            .focusRelay
            .filter { $0 == .off(.endEditing) }
            .mapToVoid()
            .withLatestFrom(noteModel.textRelay)
            .withLatestFrom(noteModel.originalTextRelay) { text, originalText in
                text != originalText ? text : nil
            }
            .compactMap { $0 }
            .distinctUntilChanged()
            .show(loader: loadingViewPresenter, style: .circle)
            .delay(.milliseconds(200), scheduler: MainScheduler.asyncInstance)
            .flatMap(weak: self) { (self, note) in
                self.interactor
                    .updateMemo(for: self.event.identifier, to: note)
                    .hide(loader: self.loadingViewPresenter)
                    .asObservable()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    deinit {
        loadingViewPresenter.hide()
    }
}
