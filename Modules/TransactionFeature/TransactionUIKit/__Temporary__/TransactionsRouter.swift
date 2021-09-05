// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import SwiftUI
import ToolKit
import TransactionKit
import UIComponentsKit

/// Represents all types of transactions the user can perform
public enum TransactionFlowAction: Equatable {

    /// Performs a buy. If `CrytoAccount` is `nil`, the users will be presented with a crypto currency selector.
    case buy(CryptoAccount?)

    public static func == (lhs: TransactionFlowAction, rhs: TransactionFlowAction) -> Bool {
        switch (lhs, rhs) {
        case (.buy(let lhsAccount), .buy(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        }
    }
}

/// Represents the possible outcomes of going through the transaction flow
public enum TransactionFlowResult: Equatable {
    case abandoned
    case completed
}

/// A protocol defining the API for the app's entry point to any `Transaction Flow`.
/// NOTE: Presenting a Transaction Flow can never fail because it's expected for any error to be handled within the flow. Non-recoverable errors should force the user to abandon the flow.
public protocol TransactionsRouterAPI {

    func presentTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never>
}

public protocol KYCSDDServiceAPI {
    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never>
    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<Bool, Never>
}

internal final class TransactionsRouter: TransactionsRouterAPI {

    private let featureFlagsService: InternalFeatureFlagServiceAPI
    private let legacyBuyPresenter: LegacyBuyFlowPresenter
    private let buyFlowBuilder: BuyFlowBuildable

    // Since RIBs need to be attached to something but we're not, the router in use needs to be retained.
    private var currentRIBRouter: RIBs.Routing?

    init(
        featureFlagsService: InternalFeatureFlagServiceAPI = resolve(),
        legacyBuyPresenter: LegacyBuyFlowPresenter = .init(),
        buyFlowBuilder: BuyFlowBuildable = BuyFlowBuilder()
    ) {
        self.featureFlagsService = featureFlagsService
        self.legacyBuyPresenter = legacyBuyPresenter
        self.buyFlowBuilder = buyFlowBuilder
    }

    func presentTransactionFlow(
        to action: TransactionFlowAction,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        switch action {
        case .buy(let cryptoAccount):
            if featureFlagsService.isEnabled(.useTransactionsFlowToBuyCrypto) {
                return presentTransactionFlow(with: cryptoAccount, from: presenter)
            }
            return presentLegacyTransactionFlow(toBuy: cryptoAccount?.asset, from: presenter)
        }
    }
}

extension TransactionsRouter {

    // since we're not attaching a RIB to a RootRouter we have to retain the router and manually activate it
    private func mimicRIBAttachment(router: RIBs.Routing) {
        currentRIBRouter?.interactable.deactivate()
        currentRIBRouter = router
        router.load()
        router.interactable.activate()
    }
}

// MARK: - Buy

extension TransactionsRouter {

    private func presentTransactionFlow(
        with cryptoAccount: CryptoAccount?,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        let listener = BuyFlowListener()
        let interactor = BuyFlowInteractor()
        let router = buyFlowBuilder.build(with: listener, interactor: interactor)
        router.start(with: cryptoAccount, from: presenter)
        mimicRIBAttachment(router: router)
        return listener.publisher
    }

    private func presentLegacyTransactionFlow(
        toBuy cryptoCurrency: CryptoCurrency?,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        // NOTE: right now the user locale is used to determine the fiat currency to use here but eventually we'll ask the user to provide that like we do for simple buy (IOS-4819)
        let fiatCurrency: FiatCurrency = .locale

        guard let cryptoCurrency = cryptoCurrency else {
            return legacyBuyPresenter.presentBuyFlowWithTargetCurrencySelectionIfNecessary(
                from: presenter,
                using: fiatCurrency
            )
        }
        return legacyBuyPresenter.presentBuyScreen(
            from: presenter,
            targetCurrency: cryptoCurrency,
            sourceCurrency: fiatCurrency
        )
    }
}

// MARK: - Legacy Buy Implementation

class LegacyBuyFlowPresenter {

    private enum CrytoSelectionResult {
        case abandoned
        case select(CryptoCurrency)
    }

    private let cryptoCurrenciesService: CryptoCurrenciesServiceAPI
    private let kycService: KYCSDDServiceAPI

    private var buyRouter: PlatformUIKit.Router! // reference stored otherwise the app crashes for some reason 😕

    init(
        cryptoCurrenciesService: CryptoCurrenciesServiceAPI = resolve(),
        kycService: KYCSDDServiceAPI = resolve()
    ) {
        self.cryptoCurrenciesService = cryptoCurrenciesService
        self.kycService = kycService
    }

    func presentBuyFlowWithTargetCurrencySelectionIfNecessary(
        from presenter: UIViewController,
        using fiatCurrency: FiatCurrency
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        // Step 1. check SDD eligibility to understand which flow to show next
        kycService.checkSimplifiedDueDiligenceEligibility()
            .receive(on: DispatchQueue.main)
            .flatMap { [weak self] userIsSDDEligible -> AnyPublisher<TransactionFlowResult, Never> in
                guard let self = self else {
                    unexpectedDeallocation()
                }
                guard userIsSDDEligible else {
                    // Step 2 (non-SDD eligible). Step Present present simple buy flow
                    return self.presentSimpleBuyScreen(from: presenter)
                }
                // Step 2a. present currency selection screen
                return self.presentCryptoCurrencySelectionScreen(from: presenter, fiatCurrency: fiatCurrency)
                    .flatMap { [weak self] result -> AnyPublisher<TransactionFlowResult, Never> in
                        guard let self = self else {
                            unexpectedDeallocation()
                        }
                        // Step 2b. present buy flow screen for selected crypto and locale's fiat currency
                        guard case .select(let cryptoCurrency) = result else {
                            return .just(.abandoned)
                        }
                        return self.presentBuyScreen(
                            from: presenter,
                            targetCurrency: cryptoCurrency,
                            sourceCurrency: fiatCurrency
                        )
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func presentCryptoCurrencySelectionScreen(
        from presenter: UIViewController,
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<CrytoSelectionResult, Never> {
        let publisher = PassthroughSubject<CrytoSelectionResult, Never>()
        presenter.present(
            NavigationView {
                CryptoCurrencySelectionView(
                    store: Store(
                        initialState: CryptoCurrencySelectionState(),
                        reducer: cryptoCurrencySelectionReducer,
                        environment: CryptoCurrencySelectionEnvironment(
                            mainQueue: .main,
                            close: {
                                publisher.send(.abandoned)
                                publisher.send(completion: .finished)
                            },
                            select: { selectedCryptoCurrency in
                                publisher.send(.select(selectedCryptoCurrency))
                            },
                            loadCryptoCurrencies: { [cryptoCurrenciesService] in
                                cryptoCurrenciesService.fetchPurchasableCryptoCurrencies(using: fiatCurrency)
                            }
                        )
                    )
                )
                .whiteNavigationBarStyle()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        )
        return publisher.eraseToAnyPublisher()
    }

    private func presentSimpleBuyScreen(from presenter: UIViewController) -> AnyPublisher<TransactionFlowResult, Never> {
        // This is just levereging the existing buy flow, which isn't great but is getting replaced buy the new `Transactions` implementation
        presentBuyScreen(
            from: presenter,
            targetCurrency: .coin(.bitcoin), // not important for simple buy
            sourceCurrency: .locale, // not imporant for simple buy
            isSDDEligible: false
        )
    }

    func presentBuyScreen(
        from presenter: UIViewController,
        targetCurrency: CryptoCurrency,
        sourceCurrency: FiatCurrency,
        isSDDEligible: Bool = true
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        // This is just levereging the existing buy flow, which isn't great but is getting replaced buy the new `Transactions` implementation
        let presentBuy = {
            let builder = PlatformUIKit.Builder(
                stateService: PlatformUIKit.StateService()
            )
            self.buyRouter = PlatformUIKit.Router(builder: builder, currency: targetCurrency)
            self.buyRouter.start(skipIntro: isSDDEligible)
        }

        // The current buy flow implementation is too complex to modify to get a callback
        // so, for now, dimiss any previously presented and present the buy flow. Then return an empty publisher.
        if presenter.presentedViewController != nil {
            presenter.dismiss(animated: true, completion: presentBuy)
        } else {
            presentBuy()
        }
        return Empty(completeImmediately: true)
            .eraseToAnyPublisher()
    }
}
