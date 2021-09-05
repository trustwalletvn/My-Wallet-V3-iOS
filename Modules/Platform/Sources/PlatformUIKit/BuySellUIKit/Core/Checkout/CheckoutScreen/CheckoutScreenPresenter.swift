// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CheckoutScreenPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout

    // MARK: - Navigation Properties

    let reloadRelay: PublishRelay<Void> = .init()

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    // MARK: - Screen Properties

    let buttons: [ButtonViewModel]

    var cells: [DetailsScreen.CellType] {
        contentReducer.cells
    }

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let interactor: CheckoutScreenInteractor
    private let checkoutRouting: CheckoutRoutingInteracting
    private let loader: LoadingViewPresenting
    private let alert: AlertViewPresenterAPI
    private let errorRecorder: ErrorRecording

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let contentReducer: CheckoutScreenContentReducing

    // MARK: - Setup

    init(
        checkoutRouting: CheckoutRoutingInteracting,
        contentReducer: CheckoutScreenContentReducing,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        loader: LoadingViewPresenting = resolve(),
        alert: AlertViewPresenterAPI = resolve(),
        interactor: CheckoutScreenInteractor
    ) {
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
        self.checkoutRouting = checkoutRouting
        self.loader = loader
        self.alert = alert
        self.interactor = interactor
        self.contentReducer = contentReducer

        // MARK: Nav Bar

        titleViewRelay.accept(.text(value: contentReducer.title))

        // MARK: Buttons Setup

        buttons = [
            contentReducer.cancelButtonViewModel,
            contentReducer.continueButtonViewModel
        ]
        .compactMap { $0 }

        contentReducer.continueButtonViewModel
            .tapRelay
            .show(loader: loader, style: .circle)
            .flatMap(weak: self) { (self, _) in
                self.interactor.continue()
                    .mapToResult()
            }
            .hide(loader: loader)
            .bindAndCatch(weak: self) { (self, result) in
                switch result {
                case .success(let data):
                    self.checkoutRouting.actionRelay.accept(.confirm(data.0, isOrderNew: data.1))
                case .failure(let failure):
                    self.recordError(failure)
                    self.showAlertWithErrorMessage(String(describing: failure))
                }
            }
            .disposed(by: disposeBag)

        contentReducer.cancelButtonViewModel?
            .tapRelay
            .bindAndCatch(weak: self) { (self) in
                self.cancel()
            }
            .disposed(by: disposeBag)

        contentReducer.transferDetailsButtonViewModel?
            .tapRelay
            .withLatestFrom(Observable.just(interactor.checkoutData))
            .map { .bankTransferDetails($0) }
            .bindAndCatch(to: checkoutRouting.actionRelay)
            .disposed(by: disposeBag)
    }

    /// Should get called once, when the view has finished loading
    func viewDidLoad() {
        interactor.setup()
            .handleLoaderForLifecycle(loader: loader, style: .circle)
            .subscribe(
                onSuccess: { [weak self] data in
                    guard let self = self else { return }
                    self.analyticsRecorder.record(
                        event: AnalyticsEvent.sbCheckoutShown(paymentMethod: data.paymentMethod.analyticsParameter)
                    )
                    self.contentReducer.setupDidSucceed(with: data)
                },
                onError: { [weak self] error in
                    self?.setupDidFail(with: error)
                }
            )
            .disposed(by: disposeBag)
    }

    private func cancel() {
        if interactor.checkoutData.isPendingDepositBankWire {
            checkoutRouting.actionRelay.accept(.cancel(interactor.checkoutData))
        } else {
            interactor.cancelIfPossible()
                .handleLoaderForLifecycle(loader: loader, style: .circle)
                .subscribe(
                    onSuccess: { [weak self] wasCancelled in
                        guard let self = self else { return }
                        if wasCancelled {
                            self.analyticsRecorder.record(event: AnalyticsEvent.sbCheckoutCancelGoBack)
                        }
                        self.checkoutRouting.previousRelay.accept(())
                    }
                )
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Navigation

    var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction {
        .custom { [weak self] in
            self?.cancel()
        }
    }

    var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction {
        .custom { [weak self] in
            self?.checkoutRouting.previousRelay.accept(())
        }
    }

    /// Is called as the interaction setup fails
    /// Record the error and then show an alert. After an alert
    /// the flow returns to the prior screen.
    private func setupDidFail(with error: Error) {
        recordError(error)
        showAlertWithErrorMessageAndCancelTransaction(String(describing: error))
    }

    private func recordError(_ error: Error) {
        Logger.shared.error(error)
        errorRecorder.error(error)
    }

    private func showAlertWithErrorMessage(_ message: String?) {
        alert.error(
            in: nil,
            message: message,
            action: nil
        )
    }

    private func showAlertWithErrorMessageAndCancelTransaction(_ message: String?) {
        alert.error(in: nil, message: message) { [weak self] in
            self?.cancel()
        }
    }
}
