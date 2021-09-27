// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import PlatformKit
import RxSwift

final class EthereumActivityDetailsInteractor {

    // MARK: - Private Properties

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails>
    private let wallet: EthereumWalletBridgeAPI

    // MARK: - Init

    init(
        wallet: EthereumWalletBridgeAPI = resolve(),
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        detailsService: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> = resolve()
    ) {
        self.detailsService = detailsService
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
        self.wallet = wallet
    }

    // MARK: - Public Functions

    func updateMemo(for identifier: String, to memo: String?) -> Completable {
        wallet.updateMemo(for: identifier, memo: memo)
    }

    func details(identifier: String, createdAt: Date) -> Observable<EthereumActivityDetailsViewModel> {
        let transaction = detailsService
            .details(for: identifier)
        let memo = self.memo(for: identifier)
            .catchErrorJustReturn(nil)
        let price = self.price(at: createdAt)
            .optional()
            .catchErrorJustReturn(nil)

        return Observable
            .combineLatest(
                transaction,
                price.asObservable(),
                memo.asObservable()
            )
            .map { EthereumActivityDetailsViewModel(details: $0, price: $1?.moneyValue.fiatValue, memo: $2) }
    }

    // MARK: - Private Functions

    private func memo(for identifier: String) -> Single<String?> {
        wallet.memo(for: identifier)
    }

    private func price(at date: Date) -> Single<PriceQuoteAtTime> {
        fiatCurrencySettings
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.price(at: date, in: fiatCurrency)
            }
    }

    private func price(at date: Date, in fiatCurrency: FiatCurrency) -> Single<PriceQuoteAtTime> {
        priceService.price(
            of: CurrencyType.crypto(.coin(.ethereum)),
            in: fiatCurrency,
            at: date
        )
        .asSingle()
    }
}
