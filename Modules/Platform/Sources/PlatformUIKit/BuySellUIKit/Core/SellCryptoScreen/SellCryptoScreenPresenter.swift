// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class SellCryptoScreenPresenter: EnterAmountScreenPresenter {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.SellCryptoScreen

    // MARK: - Properties

    private let auxiliaryViewPresenter: SendAuxiliaryViewPresenter
    private let interactor: SellCryptoScreenInteractor
    private let routerInteractor: SellRouterInteractor
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        interactor: SellCryptoScreenInteractor,
        routerInteractor: SellRouterInteractor,
        backwardsNavigation: @escaping () -> Void
    ) {
        self.routerInteractor = routerInteractor
        self.interactor = interactor
        auxiliaryViewPresenter = SendAuxiliaryViewPresenter(
            interactor: interactor.auxiliaryViewInteractor,
            initialState: SendAuxiliaryViewPresenter.State(
                maxButtonVisibility: .visible,
                networkFeeVisibility: .hidden,
                bitpayVisibility: .hidden,
                availableBalanceTitle: LocalizedString.available,
                maxButtonTitle: LocalizedString.useMax
            )
        )
        super.init(
            inputTypeToggleVisibility: .visible,
            backwardsNavigation: backwardsNavigation,
            displayBundle: .sell(cryptoCurrency: interactor.data.source.currencyType.cryptoCurrency!),
            interactor: interactor
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.amountTranslationInteractor.minAmountSelectedRelay
            .map { [interactor] _ in
                AnalyticsEvents.New.Sell.sellAmountMinClicked(
                    fromAccountType: .init(interactor.data.source),
                    inputCurrency: interactor.data.source.currencyType.code,
                    outputCurrency: interactor.data.destination.currencyType.code
                )
            }
            .subscribe(onNext: analyticsRecorder.record(event:))
            .disposed(by: disposeBag)

        topSelectionButtonViewModel.isButtonEnabledRelay.accept(false)
        topSelectionButtonViewModel.trailingContentRelay.accept(.empty)
        bottomAuxiliaryViewModelStateRelay.accept(.maxAvailable(auxiliaryViewPresenter))
        topSelectionButtonViewModel.titleRelay.accept(
            String(format: LocalizedString.from, interactor.data.source.currencyType.code)
        )
        topSelectionButtonViewModel.subtitleRelay.accept(
            String(format: LocalizedString.to, interactor.data.destination.currencyType.code)
        )

        struct CTAData {
            let kycState: KycState
            let isSimpleBuyEligible: Bool
            let candidateOrderDetails: CandidateOrderDetails
        }

        let ctaObservable = continueButtonTapped
            .asObservable()
            .withLatestFrom(interactor.candidateOrderDetails)
            .compactMap { $0 }
            .show(loader: loader, style: .circle)
            .flatMap { [analyticsRecorder, interactor] candidateOrderDetails -> Observable<Result<CTAData, Error>> in
                Observable.zip(
                    interactor.currentKycState.asObservable(),
                    interactor.currentEligibilityState
                )
                .map { currentKycState, currentEligibilityState -> Result<CTAData, Error> in
                    switch (currentKycState, currentEligibilityState) {
                    case (.success(let kycState), .success(let isSimpleBuyEligible)):
                        let ctaData = CTAData(
                            kycState: kycState,
                            isSimpleBuyEligible: isSimpleBuyEligible,
                            candidateOrderDetails: candidateOrderDetails
                        )
                        analyticsRecorder.record(event:
                            AnalyticsEvents.New.Sell.sellAmountEntered(
                                fromAccountType: .init(interactor.data.source),
                                inputAmount: candidateOrderDetails.cryptoValue.displayMajorValue.doubleValue,
                                inputCurrency: candidateOrderDetails.cryptoCurrency.code,
                                outputCurrency: candidateOrderDetails.fiatCurrency.code
                            )
                        )
                        return .success(ctaData)
                    case (.failure(let error), .success):
                        return .failure(error)
                    case (.success, .failure(let error)):
                        return .failure(error)
                    case (.failure(let error), .failure):
                        return .failure(error)
                    }
                }
            }
            .share()

        ctaObservable
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { [loader, routerInteractor] (self, result) in
                switch result {
                case .success(let data):
                    switch (data.kycState, data.isSimpleBuyEligible) {
                    case (.completed, false):
                        loader.hide()
                    // TODO: inelligible
                    case (.completed, true):
                        self.createOrder(from: data.candidateOrderDetails) { checkoutData in
                            loader.hide()
                            routerInteractor.nextFromSellCrypto(checkoutData: checkoutData)
                        }
                    case (.shouldComplete, _):
                        self.createOrder(from: data.candidateOrderDetails) { _ in
                            loader.hide()
                            // TODO: KYC with checkout data
                        }
                    }
                case .failure(let error):
                    self.handle(error)
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Private methods

    private func createOrder(
        from candidateOrderDetails: CandidateOrderDetails,
        with completion: @escaping (CheckoutData) -> Void
    ) {

        interactor.createOrder(from: candidateOrderDetails)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: completion,
                onError: { [weak self] error in
                    self?.handle(error)
                }
            )
            .disposed(by: disposeBag)
    }
}
