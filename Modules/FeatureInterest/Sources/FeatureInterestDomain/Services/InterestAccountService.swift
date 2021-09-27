// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class InterestAccountService: InterestAccountServiceAPI {

    // MARK: - Private Properties

    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let priceService: PriceServiceAPI
    private let cachedValue: CachedValue<InterestAccountBalances>
    private let interestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI
    private let interestAccountLimitsRepository: InterestAccountLimitsRepositoryAPI
    private let interestAccountEligibilityRepository: InterestAccountEligibilityRepositoryAPI
    private let interestAccountRateRepository: InterestAccountRateRepositoryAPI

    // MARK: - Setup

    init(
        interestAccountBalanceRepository: InterestAccountBalanceRepositoryAPI = resolve(),
        interestAccountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve(),
        interestAccountEligibilityRepository: InterestAccountEligibilityRepositoryAPI = resolve(),
        interestAccountRateRepository: InterestAccountRateRepositoryAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve()
    ) {
        self.interestAccountRateRepository = interestAccountRateRepository
        self.interestAccountEligibilityRepository = interestAccountEligibilityRepository
        self.interestAccountLimitsRepository = interestAccountLimitsRepository
        self.interestAccountBalanceRepository = interestAccountBalanceRepository
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiersService = kycTiersService
        cachedValue = CachedValue(configuration: .periodic(60))
        cachedValue.setFetch(weak: self) { (self) in
            self.fetchBalancesResponse()
        }
    }

    // MARK: - InterestAccountServiceAPI

    func fetchInterestAccountLimitsForCryptoCurrency(
        _ currency: CryptoCurrency
    ) -> Single<InterestAccountLimits?> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) in
                self.interestAccountLimitsRepository
                    .fetchInterestAccountLimitsForAllAssets(fiatCurrency)
                    .asObservable()
                    .take(1)
                    .asSingle()
            }
            .map { $0.filter { $0.cryptoCurrency == currency } }
            .map(\.first)
    }

    func fetchInterestAccountDetailsForCryptoCurrency(
        _ currency: CryptoCurrency
    ) -> Single<ValueCalculationState<InterestAccountBalanceDetails>> {
        details(for: currency)
    }

    func details(for currency: CryptoCurrency) -> Single<ValueCalculationState<InterestAccountBalanceDetails>> {
        cachedValue.valueSingle
            .map { response -> ValueCalculationState<InterestAccountBalanceDetails> in
                switch response[currency] {
                case .none:
                    return .invalid(.empty)
                case .some(let details):
                    return .value(details)
                }
            }
    }

    func balances(fetch: Bool) -> Single<CustodialAccountBalanceStates> {
        (fetch ? cachedValue.fetchValue : cachedValue.valueSingle)
            .map { CustodialAccountBalanceStates(balances: $0) }
    }

    // MARK: - SavingsOverviewAPI

    func balance(for currency: CryptoCurrency) -> Single<CustodialAccountBalanceState> {
        balances(fetch: false)
            .map { $0[currency.currency] }
    }

    func rate(for currency: CryptoCurrency) -> Single<Double> {
        interestAccountRateRepository
            .fetchInteretAccountRateForCryptoCurrency(currency)
            .map(\.rate)
            .asObservable()
            .take(1)
            .asSingle()
    }

    private func fetchBalancesResponse() -> Single<InterestAccountBalances> {
        Single
            .zip(
                kycTiersService.tiers.map(\.isTier2Approved),
                fiatCurrencyService.fiatCurrency
            )
            .flatMap(weak: self) { (self, values) -> Single<InterestAccountBalances?> in
                let (tier2Approved, fiatCurrency) = values
                guard tier2Approved else {
                    return .just(nil)
                }
                return self.interestAccountBalanceRepository
                    .fetchInterestAccountBalanceStates(fiatCurrency)
                    .asObservable()
                    .take(1)
                    .asSingle()
                    .optional()
            }
            .catchErrorJustReturn(nil)
            .onNilJustReturn(.empty)
    }
}
