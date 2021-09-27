// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import FeatureTransactionDomain
import PlatformKit // replace with MoneyKit when available
import SwiftUI
import ToolKit
import UIComponentsKit

struct CryptoCurrencySelectionState: Equatable {
    var cryptoCurrencies: IdentifiedArrayOf<CryptoCurrencyQuote> = []
    var loadingCryptoCurrencies: Bool = false
    var loadingErrorAlert: AlertState<CryptoCurrencySelectionAction>?
}

enum CryptoCurrencySelectionAction: Equatable {
    case didReceiveCryptoLoadingResponse(Result<[CryptoCurrencyQuote], CryptoCurrenciesServiceError>)
    case dismissLoadingAlert
    case loadCryptoCurrencies
    case closeButtonTapped
    case cellTapped(CryptoCurrencyQuote.ID, CryptoCurrencyQuoteAction)
    case skipButtonTapped
}

struct CryptoCurrencySelectionEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let close: () -> Void
    let select: (CryptoCurrency) -> Void
    let loadCryptoCurrencies: () -> AnyPublisher<[CryptoCurrencyQuote], CryptoCurrenciesServiceError>
}

typealias CryptoCurrencySelectionReducer = Reducer<
    CryptoCurrencySelectionState,
    CryptoCurrencySelectionAction,
    CryptoCurrencySelectionEnvironment
>

let cryptoCurrencySelectionReducer = CryptoCurrencySelectionReducer { state, action, environment in
    switch action {
    case .didReceiveCryptoLoadingResponse(let result):
        state.loadingCryptoCurrencies = false
        switch result {
        case .success(let cryptoCurrencies):
            state.cryptoCurrencies = .init(cryptoCurrencies)
        case .failure(let error):
            state.loadingErrorAlert = AlertState(
                title: TextState("Something went wrong"),
                message: TextState("Couldn't load a list of available cryptocurrencies: \(String(describing: error))"),
                primaryButton: .default(
                    TextState("Retry"),
                    action: .send(.loadCryptoCurrencies)
                ),
                secondaryButton: .cancel()
            )
        }
        return .none

    case .dismissLoadingAlert:
        state.loadingErrorAlert = nil
        return .none

    case .loadCryptoCurrencies:
        state.loadingCryptoCurrencies = true
        return environment.loadCryptoCurrencies()
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result in
                .didReceiveCryptoLoadingResponse(result)
            }

    case .cellTapped(_, let subAction):
        switch subAction {
        case .select(let quote):
            environment.select(quote.cryptoCurrency)
        }
        return .none

    case .closeButtonTapped:
        environment.close()
        return .none

    case .skipButtonTapped:
        environment.close()
        return .none
    }
}

struct CryptoCurrencySelectionView: View {

    let store: Store<CryptoCurrencySelectionState, CryptoCurrencySelectionAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: .zero) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text("Want to Buy Crypto?")
                        .textStyle(.title)
                    Text("Select the crypto you want to buy and link a debit or credit card.")
                        .textStyle(.subheading)
                }
                .padding()

                if viewStore.cryptoCurrencies.isEmpty, viewStore.loadingCryptoCurrencies {
                    Spacer()
                    ActivityIndicatorView()
                    Spacer()
                } else if viewStore.cryptoCurrencies.isEmpty {
                    Spacer()
                    VStack {
                        Text("No purchasable pairs found")
                            .textStyle(.body)
                        PrimaryButton(title: "Retry") {
                            viewStore.send(.loadCryptoCurrencies)
                        }
                    }
                    .padding()
                    Spacer()
                } else {
                    Divider()
                    List {
                        ForEachStore(store.scope(state: \.cryptoCurrencies, action: CryptoCurrencySelectionAction.cellTapped)) { cellStore in
                            CryptoCurrencyQuoteCell(store: cellStore)
                        }
                    }
                }

                SecondaryButton(title: "Not Now") {
                    viewStore.send(.skipButtonTapped)
                }
                .padding()
            }
            .onAppear {
                viewStore.send(.loadCryptoCurrencies)
            }
            .trailingNavigationButton(.close) {
                viewStore.send(.closeButtonTapped)
            }
            .alert(store.scope(state: \.loadingErrorAlert), dismiss: .dismissLoadingAlert)
        }
    }
}

#if DEBUG
struct SDDIntroBuyView_Previews: PreviewProvider {

    static var testCurrencyPairs = [
        CryptoCurrencyQuote(
            cryptoCurrency: .coin(.bitcoin),
            fiatCurrency: .USD,
            quote: 5000000,
            formattedQuote: "$50,000",
            priceChange: 10.0,
            formattedPriceChange: "+10.00%",
            timestamp: Date()
        ),
        CryptoCurrencyQuote(
            cryptoCurrency: .coin(.ethereum),
            fiatCurrency: .USD,
            quote: 150000,
            formattedQuote: "$1,500",
            priceChange: -5.0,
            formattedPriceChange: "-5.00%",
            timestamp: Date()
        ),
        CryptoCurrencyQuote(
            cryptoCurrency: .coin(.bitcoinCash),
            fiatCurrency: .USD,
            quote: 100,
            formattedQuote: "$1,00",
            priceChange: 0.0,
            formattedPriceChange: "0.00%",
            timestamp: Date()
        )
    ]

    static var previews: some View {
        Group {
            CryptoCurrencySelectionView(
                store: .init(
                    initialState: CryptoCurrencySelectionState(
                        loadingCryptoCurrencies: true
                    ),
                    reducer: cryptoCurrencySelectionReducer,
                    environment: CryptoCurrencySelectionEnvironment(
                        mainQueue: .main,
                        close: {},
                        select: { _ in },
                        loadCryptoCurrencies: { .just([]) }
                    )
                )
            )
            CryptoCurrencySelectionView(
                store: .init(
                    initialState: CryptoCurrencySelectionState(
                        cryptoCurrencies: .init(testCurrencyPairs)
                    ),
                    reducer: cryptoCurrencySelectionReducer,
                    environment: CryptoCurrencySelectionEnvironment(
                        mainQueue: .main,
                        close: {},
                        select: { _ in },
                        loadCryptoCurrencies: { .just(testCurrencyPairs) }
                    )
                )
            )
        }
    }
}
#endif
