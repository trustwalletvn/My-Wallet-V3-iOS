// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift
import ToolKit

final class EligibilityService: EligibilityServiceAPI {

    // MARK: - Properties

    var isEligible: Single<Bool> {
        isEligibileValue.valueSingle
    }

    private let isEligibileValue: CachedValue<Bool>
    private let client: EligibilityClientAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let fiatCurrencyService: FiatCurrencySettingsServiceAPI

    // MARK: - Setup

    init(
        client: EligibilityClientAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = resolve(),
        fiatCurrencyService: FiatCurrencySettingsServiceAPI = resolve()
    ) {
        self.client = client
        self.reactiveWallet = reactiveWallet
        self.fiatCurrencyService = fiatCurrencyService
        isEligibileValue = CachedValue(
            configuration: .periodic(30)
        )

        isEligibileValue.setFetch(weak: self) { (self) in
            self.reactiveWallet.waitUntilInitializedSingle
                .flatMap(weak: self) { (self, _) -> Single<Bool> in
                    self.fiatCurrencyService.fiatCurrency
                        .flatMap { currency -> Single<EligibilityResponse> in
                            self.client.isEligible(
                                for: currency.code,
                                methods: [
                                    PaymentMethodPayloadType.bankTransfer.rawValue,
                                    PaymentMethodPayloadType.card.rawValue
                                ]
                            )
                        }
                        .map(\.eligible)
                }
        }
    }

    func fetch() -> Single<Bool> {
        isEligibileValue.fetchValue
    }
}
