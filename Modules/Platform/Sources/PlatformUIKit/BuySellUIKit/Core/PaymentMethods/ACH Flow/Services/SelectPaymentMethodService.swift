// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

public final class SelectPaymentMethodService {

    // MARK: - Properties

    /// Streams all the available payment methods, this includes suggested and valid payments
    var methods: Single<[PaymentMethodType]> {
        let methodTypes = paymentMethodTypesService.methodTypes
            .take(1)
            .asSingle()

        return Single
            .zip(
                isUserEligibleForFunds,
                methodTypes,
                fiatCurrencyService.fiatCurrency
            )
            .map { payload in
                let (isUserEligibleForFunds, methods, fiatCurrency) = payload
                return methods
                    .filterValidForBuy(
                        currentWalletCurrency: fiatCurrency,
                        accountForEligibility: isUserEligibleForFunds
                    )
            }
    }

    /// Streams the suggested payment methods that a customer can add (credit-card, linked bank, deposit)
    var suggestedMethods: Single<[PaymentMethodType]> {
        methods.map { types -> [PaymentMethodType] in
            types.filter(\.isSuggested)
        }
    }

    /// Streams the available payment methods that a customer can use
    var paymentMethods: Single<[PaymentMethodType]> {
        methods.map { types -> [PaymentMethodType] in
            types.filter { type -> Bool in
                !type.isSuggested
            }
        }
    }

    var isUserEligibleForFunds: Single<Bool> {
        kycTiers.tiers.map(\.isTier2Approved)
    }

    // MARK: - Injected

    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let kycTiers: KYCTiersServiceAPI

    // MARK: - Setup

    public init(
        paymentMethodTypesService: PaymentMethodTypesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        kycTiers: KYCTiersServiceAPI = resolve()
    ) {
        self.paymentMethodTypesService = paymentMethodTypesService
        self.fiatCurrencyService = fiatCurrencyService
        self.kycTiers = kycTiers
    }

    func select(method: PaymentMethodType) {
        paymentMethodTypesService.preferredPaymentMethodTypeRelay.accept(method)
    }
}
