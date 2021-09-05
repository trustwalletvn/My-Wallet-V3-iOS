// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class BankTransferDetailScreenPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.TransferDetails
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    // MARK: - Screen Properties

    let reloadRelay: PublishRelay<Void> = .init()

    private(set) var buttons: [ButtonViewModel] = []

    private(set) var cells: [DetailsScreen.CellType] = []

    // MARK: - Navigation Properties

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(leading: .none, trailing: .none, barStyle: .darkContent())
    }

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let contentReducer: ContentReducer

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let webViewRouter: WebViewRouterAPI
    private let stateService: StateServiceAPI
    private let interactor: BankTransferDetailScreenInteractor

    // MARK: - Setup

    init(
        webViewRouter: WebViewRouterAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        interactor: BankTransferDetailScreenInteractor,
        stateService: StateServiceAPI
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.webViewRouter = webViewRouter
        self.interactor = interactor
        self.stateService = stateService

        contentReducer = ContentReducer(
            data: interactor.checkoutData,
            analyticsRecorder: analyticsRecorder
        )

        // MARK: Nav Bar

        titleViewRelay.accept(.text(value: contentReducer.title))

        // MARK: Continue Button Setup

        let continueButtonViewModel = ButtonViewModel.primary(with: LocalizedString.Button.ok)
        continueButtonViewModel.tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.stateService.nextRelay.accept(())
            }
            .disposed(by: disposeBag)
        continueButtonViewModel
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsFinished)
            }
            .disposed(by: disposeBag)
        buttons.append(continueButtonViewModel)

        // MARK: Cells Setup

        let summary = LabelContent(
            text: contentReducer.summary,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.descriptionLabel)
        )

        let notice = NoticeViewModel(
            imageViewContent: .init(
                imageResource: .local(name: "disclaimer-icon", bundle: .platformUIKit),
                accessibility: .id(AccessibilityId.disclaimerImage)
            ),
            labelContents: .init(
                text: LocalizedString.disclaimer,
                font: .main(.medium, 12),
                color: .descriptionText,
                accessibility: .id(AccessibilityId.disclaimerLabel)
            ),
            verticalAlignment: .top
        )

        let totalCost = TransactionalLineItem
            .totalCost(interactor.checkoutData.order.inputValue.displayString)
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)

        cells.append(.staticLabel(summary))
        cells.append(.separator)
        contentReducer
            .lineItems
            .forEach { cells.append(.lineItem($0)) }
        cells.append(.lineItem(totalCost))
        cells.append(.separator)
        cells.append(.notice(notice))

        if let termsTextViewModel = contentReducer.termsTextViewModel {
            termsTextViewModel.tap
                .bindAndCatch(to: webViewRouter.launchRelay)
                .disposed(by: disposeBag)
            cells.append(.interactableTextCell(termsTextViewModel))
        }
    }

    // MARK: - View Life Cycle

    func viewDidLoad() {
        let currencyCode = interactor.checkoutData.order.inputValue.currencyCode
        analyticsRecorder.record(event: AnalyticsEvent.sbBankDetailsShown(currencyCode: currencyCode))
    }
}

// MARK: - Content Reducer

extension BankTransferDetailScreenPresenter {

    final class ContentReducer {

        let title: String
        let summary: String
        let lineItems: [LineItemCellPresenting]
        let termsTextViewModel: InteractableTextViewModel!

        init(
            data: CheckoutData,
            analyticsRecorder: AnalyticsEventRecorderAPI
        ) {
            typealias SummaryString = LocalizedString.Summary
            typealias TitleString = LocalizedString.Title
            let currency = data.order.inputValue.currencyType
            let currencyString = "\(currency.name) (\(currency.symbol))"

            title = TitleString.checkout
            switch data.order.inputValue.currencyType {
            case .crypto:
                summary = "\(SummaryString.AnyFiat.prefix) \(currencyString) \(SummaryString.AnyFiat.suffix)"
            case .fiat(let fiatType):
                switch fiatType {
                case .USD,
                     .GBP:
                    summary = "\(SummaryString.GbpAndUsd.prefix) \(currencyString) \(SummaryString.GbpAndUsd.suffix)"
                default:
                    summary = "\(SummaryString.AnyFiat.prefix) \(currencyString) \(SummaryString.AnyFiat.suffix)"
                }
            }

            let account = data.paymentAccount!
            lineItems = account.fields.transferDetailsCellsPresenting(analyticsRecorder: analyticsRecorder)

            switch currency {
            case .fiat(let fiatType):
                switch fiatType {
                case .GBP:
                    typealias LinkString = LocalizedString.TermsLink.GBP
                    let font = UIFont.main(.medium, 12)
                    termsTextViewModel = InteractableTextViewModel(
                        inputs: [
                            .text(string: LinkString.prefix),
                            .url(string: LinkString.link, url: TermsUrlLink.gbp),
                            .text(string: LinkString.suffix)
                        ],
                        textStyle: .init(color: .descriptionText, font: font),
                        linkStyle: .init(color: .linkableText, font: font)
                    )
                default:
                    termsTextViewModel = nil
                }
            default:
                termsTextViewModel = nil
            }
        }
    }
}

extension Array where Element == PaymentAccountProperty.Field {
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    fileprivate func transferDetailsCellsPresenting(analyticsRecorder: AnalyticsEventRecorderAPI) -> [LineItemCellPresenting] {

        func isCopyable(field: TransactionalLineItem) -> Bool {
            switch field {
            case .paymentAccountField(.accountNumber),
                 .paymentAccountField(.iban),
                 .paymentAccountField(.bankCode),
                 .paymentAccountField(.sortCode):
                return true
            default:
                return false
            }
        }

        func analyticsEvent(field: TransactionalLineItem) -> AnalyticsEvents.SimpleBuy? {
            switch field {
            case .paymentAccountField(.bankCode):
                return .sbBankDetailsCopied(bankName: field.content ?? "")
            default:
                return nil
            }
        }

        return map { TransactionalLineItem.paymentAccountField($0) }
            .map { field in
                if isCopyable(field: field) {
                    return field.defaultCopyablePresenter(
                        analyticsEvent: analyticsEvent(field: field),
                        analyticsRecorder: analyticsRecorder,
                        accessibilityIdPrefix: AccessibilityId.lineItemPrefix
                    )
                } else {
                    return field.defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
                }
            }
    }
}
