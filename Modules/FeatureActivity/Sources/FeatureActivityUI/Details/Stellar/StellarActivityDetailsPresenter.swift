// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class StellarActivityDetailsPresenter: DetailsScreenPresenterAPI {

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

    // MARK: - Private Accessors

    private var baseCells: [DetailsScreen.CellType] {
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
            .separator
        ]
    }

    private var sendCells: [DetailsScreen.CellType] {
        baseCells + [
            .lineItem(feePresenter),
            .separator,
            .lineItem(fromPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .lineItem(memoPresenter)
        ]
    }

    private var receiveCells: [DetailsScreen.CellType] {
        baseCells + [
            .lineItem(fromPresenter),
            .separator,
            .lineItem(toPresenter),
            .separator,
            .lineItem(memoPresenter)
        ]
    }

    // MARK: - Private Properties

    private let interactor: StellarActivityDetailsInteractor
    private let router: ActivityRouterAPI
    private let disposeBag: DisposeBag = .init()
    private let event: TransactionalActivityItemEvent
    private let alertViewPresenter: AlertViewPresenterAPI

    // MARK: Private Properties (Model Relay)

    private let itemRelay: BehaviorRelay<StellarActivityDetailsViewModel?> = .init(value: nil)

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let amountPresenter: LineItemCellPresenting
    private let valuePresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting
    private let memoPresenter: LineItemCellPresenting
    private let feePresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: Private Properties (Explorer Button)

    private let explorerButton: ButtonViewModel

    // MARK: - Init

    init(
        alertViewPresenter: AlertViewPresenterAPI = resolve(),
        event: TransactionalActivityItemEvent,
        router: ActivityRouterAPI,
        interactor: StellarActivityDetailsInteractor = .init(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        precondition(event.currency == .coin(.stellar), "Using StellarActivityDetailsPresenter with \(event.currency) event.")
        self.alertViewPresenter = alertViewPresenter
        self.event = event
        self.router = router
        self.interactor = interactor
        explorerButton = .secondary(with: LocalizedString.Button.viewOnStellarChainIO)
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
        fromPresenter = TransactionalLineItem.from().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        toPresenter = TransactionalLineItem.to().defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        feePresenter = TransactionalLineItem.fee().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        memoPresenter = TransactionalLineItem.memo().defaultPresenter(
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        orderIDPresenter = TransactionalLineItem.orderId(event.transactionHash).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )
        let title: String
        switch event.type {
        case .send:
            title = LocalizedString.Title.send
            cells = sendCells
        case .receive:
            title = LocalizedString.Title.receive
            cells = receiveCells
        }
        titleViewRelay.accept(.text(value: title))
        bindAll(with: event)
    }

    // MARK: - Public Functions

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

    func bindAll(with event: TransactionalActivityItemEvent) {
        explorerButton
            .tapRelay
            .bind { [weak self] _ in
                self?.router.showBlockchainExplorer(for: event)
            }
            .disposed(by: disposeBag)

        itemRelay
            .compactMap { $0?.statusBadge }
            .distinctUntilChanged()
            .map(weak: self) { (self, _) in
                [self.statusBadge]
            }
            .bindAndCatch(to: badgesModel.badgesRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.cryptoAmount }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: cryptoAmountLabelPresenter.interactor.stateRelay)
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
            .compactMap { $0?.statusBadge }
            .distinctUntilChanged()
            .map { .loaded(next: $0) }
            .bindAndCatch(to: statusBadge.interactor.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.memo }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: memoPresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .map { $0?.fee }
            .mapToLabelContentStateInteraction()
            .bindAndCatch(to: feePresenter.interactor.description.stateRelay)
            .disposed(by: disposeBag)

        itemRelay
            .distinctUntilChanged()
            .mapToVoid()
            .bindAndCatch(to: reloadRelay)
            .disposed(by: disposeBag)
    }
}
