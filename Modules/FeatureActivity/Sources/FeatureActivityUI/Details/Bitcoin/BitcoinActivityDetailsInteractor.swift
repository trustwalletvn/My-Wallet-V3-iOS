// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinKit
import DIKit
import PlatformKit
import RxSwift

final class BitcoinActivityDetailsInteractor {

    private let fiatCurrencySettings: FiatCurrencySettingsServiceAPI
    private let priceService: PriceServiceAPI
    private let detailsService: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails>
    private let wallet: BitcoinWalletBridgeAPI

    init(
        wallet: BitcoinWalletBridgeAPI = resolve(),
        fiatCurrencySettings: FiatCurrencySettingsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        detailsService: AnyActivityItemEventDetailsFetcher<BitcoinActivityItemEventDetails> = resolve()
    ) {
        self.detailsService = detailsService
        self.fiatCurrencySettings = fiatCurrencySettings
        self.priceService = priceService
        self.wallet = wallet
    }

    private func memo(for identifier: String) -> Single<String?> {
        wallet.memo(for: identifier)
    }

    func updateMemo(for identifier: String, to memo: String?) -> Completable {
        wallet.updateMemo(for: identifier, memo: memo)
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
            of: CurrencyType.crypto(.coin(.bitcoin)),
            in: fiatCurrency,
            at: date
        )
        .asSingle()
    }

    func details(identifier: String, createdAt: Date) -> Observable<BitcoinActivityDetailsViewModel> {
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
            .map { BitcoinActivityDetailsViewModel(details: $0, price: $1?.moneyValue.fiatValue, memo: $2) }
    }
}
