// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class BitcoinActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let buttons: [ButtonViewModel]

    let cells: [DetailsScreen.CellType]

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let interactor: BitcoinActivityDetailsInteractor
    private let event: TransactionalActivityItemEvent
    private let router: ActivityRouterAPI
    private let disposeBag: DisposeBag = .init()
    private let alertViewPresenter: AlertViewPresenterAPI
    private let loadingViewPresenter: LoadingViewPresenting

    // MARK: Private Properties (Model Relay)

    private let itemRelay: BehaviorRelay<BitcoinActivityDetailsViewModel?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let amountPresenter: LineItemCellPresenting
    private let valuePresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting

    // MARK: Private Properties (TextFieldViewModel)

    private let noteModel: TextFieldViewModel

    // MARK: Private Properties (Badge)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()
    private let confirmingBadge: DefaultBadgeAssetPresenter = .init()
    private let badgeCircleModel: BadgeCircleViewModel = .init()

    // MARK: Private Properties (Explorer Button)

    private let explorerButton: ButtonViewModel

    init(
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        event: TransactionalActivityItemEvent,
        router: ActivityRouterAPI,
        interactor: BitcoinActivityDetailsInteractor = .init(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        messageRecorder: MessageRecording = resolve()
    ) {
        precondition(event.currency == .coin(.bitcoin), "Using BitcoinActivityDetailsPresenter with \(event.currency) event.")
        self.loadingViewPresenter = loadingViewPresenter
        self.alertViewPresenter = alertViewPresenter
        self.event = event
        self.interactor = interactor
        self.router = router
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
        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        noteModel = TextFieldViewModel(
            with: .description,
            validator: TextValidationFactory.General.alwaysValid,
            messageRecorder: messageRecorder
        )
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )
        cells = [
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
            .lineItem(feePresenter),
            .separator,
            .lineItem(fromPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .textField(noteModel)
        ]
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

    func bindAll(event: TransactionalActivityItemEvent) {
        let title: String
        switch event.type {
        case .send:
            title = LocalizedString.Title.send
        case .receive:
            title = LocalizedString.Title.receive
        }
        titleViewRelay.accept(.text(value: title))

        explorerButton
            .tapRelay
            .bind { [weak self] in
                self?.router.showBlockchainExplorer(for: event)
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
            .map { $0?.dateCreated }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: dateCreatedPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.amount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: amountPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: cryptoAmountLabelPresenter.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.value }
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
            .compactMap { $0?.confirmation.statusBadge }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: statusBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.fee }
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

        itemRelay
            .distinctUntilChanged()
            .mapToVoid()
            .bindAndCatch(to: reloadRelay)
            .disposed(by: disposeBag)
    }

    deinit {
        loadingViewPresenter.hide()
    }
}
