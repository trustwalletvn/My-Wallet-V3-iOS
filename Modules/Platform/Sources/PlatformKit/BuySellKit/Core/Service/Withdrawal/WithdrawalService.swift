// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import RxSwift

public protocol WithdrawalServiceAPI {
    func withdrawFeeAndLimit(for currency: FiatCurrency, paymentMethodType: PaymentMethodPayloadType) -> Single<WithdrawalFeeAndLimit>
    func withdrawal(for checkout: WithdrawalCheckoutData) -> Single<Result<FiatValue, Error>>
    func withdrawalFee(for currency: FiatCurrency, paymentMethodType: PaymentMethodPayloadType) -> Single<FiatValue>
    func withdrawalMinAmount(for currency: FiatCurrency, paymentMethodType: PaymentMethodPayloadType) -> Single<FiatValue>
}

final class WithdrawalService: WithdrawalServiceAPI {

    private let client: WithdrawalClientAPI

    init(client: WithdrawalClientAPI = resolve()) {
        self.client = client
    }

    func withdrawFeeAndLimit(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<WithdrawalFeeAndLimit> {
        client.withdrawFee(currency: currency, paymentMethodType: paymentMethodType)
            .map { response -> (CurrencyFeeResponse, CurrencyFeeResponse) in
                guard let fees = response.fees.first(where: { $0.symbol == currency.code }) else {
                    fatalError("Expected fees for currency: \(currency)")
                }
                guard let mins = response.minAmounts.first(where: { $0.symbol == currency.code }) else {
                    fatalError("Expected minimum values for currency: \(currency)")
                }
                return (fees, mins)
            }
            .map { feeResponse, minResponse -> WithdrawalFeeAndLimit in
                let zero: FiatValue = .zero(currency: currency)
                return .init(
                    minLimit: FiatValue.create(minor: minResponse.minorValue, currency: currency) ?? zero,
                    fee: FiatValue.create(minor: feeResponse.minorValue, currency: currency) ?? zero
                )
            }
            .asSingle()
    }

    func withdrawalFee(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        client.withdrawFee(currency: currency, paymentMethodType: paymentMethodType)
            .map { response -> CurrencyFeeResponse? in
                response.fees.first(where: { $0.symbol == currency.code })
            }
            .map { feeResponse -> FiatValue in
                guard let feeResponse = feeResponse,
                      let minorValue = BigInt(feeResponse.minorValue)
                else {
                    return .zero(currency: currency)
                }
                return FiatValue(amount: minorValue, currency: currency)
            }
            .asSingle()
    }

    func withdrawalMinAmount(
        for currency: FiatCurrency,
        paymentMethodType: PaymentMethodPayloadType
    ) -> Single<FiatValue> {
        client.withdrawFee(currency: currency, paymentMethodType: paymentMethodType)
            .map { response -> CurrencyFeeResponse? in
                response.minAmounts.first(where: { $0.symbol == currency.code })
            }
            .map { feeResponse -> FiatValue in
                guard let feeResponse = feeResponse,
                      let minorValue = BigInt(feeResponse.minorValue)
                else {
                    return .zero(currency: currency)
                }
                return FiatValue(amount: minorValue, currency: currency)
            }
            .asSingle()
    }

    func withdrawal(for checkout: WithdrawalCheckoutData) -> Single<Result<FiatValue, Error>> {
        client.withdraw(data: checkout)
            .asSingle()
            .mapToResult { response -> FiatValue in
                guard let amount = FiatValue.create(major: response.amount.value, currency: checkout.currency) else {
                    fatalError("Couldn't create FiatValue from withdrawal response: \(response)")
                }
                return amount
            }
    }
}
