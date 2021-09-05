// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class FundsTransferDetailScreenPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.TransferDetails
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.TransferDetails

    // MARK: - Screen Properties

    let reloadRelay: PublishRelay<Void> = .init()

    private(set) var buttons: [ButtonViewModel] = []

    private(set) var cells: [DetailsScreen.CellType] = []

    // MARK: - Navigation Properties

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction
    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance {
        .custom(
            leading: .none,
            trailing: .close,
            barStyle: .darkContent(ignoresStatusBar: false, background: .white)
        )
    }

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - Injected

    private let isOriginDeposit: Bool
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let webViewRouter: WebViewRouterAPI
    private let stateService: StateServiceAPI
    private let interactor: FundsTransferDetailsInteractorAPI

    // MARK: - Setup

    init(
        webViewRouter: WebViewRouterAPI,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        interactor: FundsTransferDetailsInteractorAPI,
        stateService: StateServiceAPI,
        isOriginDeposit: Bool
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.webViewRouter = webViewRouter
        self.interactor = interactor
        self.stateService = stateService
        self.isOriginDeposit = isOriginDeposit

        navigationBarTrailingButtonAction = .custom {
            stateService.previousRelay.accept(())
        }
    }

    func viewDidLoad() {
        analyticsRecorder.record(
            event: AnalyticsEvents.SimpleBuy.sbLinkBankScreenShown(currencyCode: interactor.fiatCurrency.code)
        )

        interactor.state
            .bindAndCatch(weak: self) { (self, state) in
                switch state {
                case .invalid(.valueCouldNotBeCalculated):
                    self.analyticsRecorder.record(
                        event: AnalyticsEvents.SimpleBuy.sbLinkBankLoadingError(
                            currencyCode: self.interactor.fiatCurrency.code
                        )
                    )
                case .value(let account):
                    self.setup(account: account)
                case .calculating, .invalid(.empty):
                    break
                }
            }
            .disposed(by: disposeBag)
    }

    private func setup(account: PaymentAccountDescribing) {
        let contentReducer = ContentReducer(
            account: account,
            isOriginDeposit: isOriginDeposit,
            analyticsRecorder: analyticsRecorder
        )

        // MARK: Nav Bar

        titleViewRelay.accept(.text(value: contentReducer.title))

        // MARK: Continue Button Setup

        let continueButtonViewModel = ButtonViewModel.primary(with: LocalizedString.Button.ok)
        continueButtonViewModel.tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.stateService.previousRelay.accept(())
            }
            .disposed(by: disposeBag)
        buttons.append(continueButtonViewModel)

        // MARK: Cells Setup

        contentReducer.lineItems
            .forEach { cells.append(.lineItem($0)) }
        cells.append(.separator)
        for noticeViewModel in contentReducer.noticeViewModels {
            cells.append(.notice(noticeViewModel))
        }

        if let termsTextViewModel = contentReducer.termsTextViewModel {
            termsTextViewModel.tap
                .bindAndCatch(to: webViewRouter.launchRelay)
                .disposed(by: disposeBag)
            cells.append(.interactableTextCell(termsTextViewModel))
        }

        reloadRelay.accept(())
    }
}

// MARK: - Content Reducer

extension FundsTransferDetailScreenPresenter {

    final class ContentReducer {

        let title: String
        let lineItems: [LineItemCellPresenting]
        let noticeViewModels: [NoticeViewModel]
        let termsTextViewModel: InteractableTextViewModel!

        init(
            account: PaymentAccountDescribing,
            isOriginDeposit: Bool,
            analyticsRecorder: AnalyticsEventRecorderAPI
        ) {

            typealias FundsString = LocalizedString.Funds

            if isOriginDeposit {
                title = "\(FundsString.Title.depositPrefix) \(account.currency)"
            } else {
                title = "\(FundsString.Title.addBankPrefix) \(account.currency) \(FundsString.Title.addBankSuffix) "
            }

            lineItems = account.fields.transferDetailsCellsPresenting(analyticsRecorder: analyticsRecorder)

            let font = UIFont.main(.medium, 12)

            let processingTimeNoticeDescription: String

            switch account.currency {
            case .GBP:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.GBP
                termsTextViewModel = InteractableTextViewModel(
                    inputs: [
                        .text(string: FundsString.Notice.recipientNameGBPPrefix),
                        .url(string: " \(FundsString.Notice.termsAndConditions) ", url: TermsUrlLink.gbp),
                        .text(string: FundsString.Notice.recipientNameGBPSuffix)
                    ],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            case .EUR:
                processingTimeNoticeDescription = FundsString.Notice.ProcessingTime.Description.EUR
                termsTextViewModel = InteractableTextViewModel(
                    inputs: [.text(string: FundsString.Notice.recipientNameEUR)],
                    textStyle: .init(color: .descriptionText, font: font),
                    linkStyle: .init(color: .linkableText, font: font)
                )
            default:
                processingTimeNoticeDescription = ""
                termsTextViewModel = nil
            }

            noticeViewModels = [
                (
                    title: FundsString.Notice.BankTransferOnly.title,
                    description: FundsString.Notice.BankTransferOnly.description,
                    image: ImageResource.local(name: "icon-bank", bundle: .platformUIKit)
                ),
                (
                    title: FundsString.Notice.ProcessingTime.title,
                    description: processingTimeNoticeDescription,
                    image: ImageResource.local(name: "clock-icon", bundle: .platformUIKit)
                )
            ]
            .map {
                NoticeViewModel(
                    imageViewContent: ImageViewContent(
                        imageResource: $0.image,
                        renderingMode: .template(.titleText)
                    ),
                    labelContents: [
                        LabelContent(
                            text: $0.title,
                            font: .main(.semibold, 12),
                            color: .titleText
                        ),
                        LabelContent(
                            text: $0.description,
                            font: .main(.medium, 12),
                            color: .descriptionText
                        )
                    ],
                    verticalAlignment: .top
                )
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
            case .paymentAccountField:
                return .sbLinkBankDetailsCopied
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
