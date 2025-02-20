// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public final class FundsAndBankOrderCheckoutInteractor {

    typealias InteractionData = Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)>

    private enum InteractionError: Error {
        case missingOrderFee
        case orderIsNotPendingDepositBankTransfer
        case unsupportedQuoteParameters

        var localizedDescription: String {
            switch self {
            case .missingOrderFee:
                return "Order fee is missing"
            case .orderIsNotPendingDepositBankTransfer:
                return "Order is not a pending deposit bank transfer"
            case .unsupportedQuoteParameters:
                return "Order must have parameters for fetching quote"
            }
        }
    }

    private let paymentAccountService: PaymentAccountServiceAPI
    private let orderQuoteService: OrderQuoteServiceAPI
    private let orderCreationService: OrderCreationServiceAPI
    private let linkedBanksService: LinkedBanksServiceAPI

    public init(
        paymentAccountService: PaymentAccountServiceAPI = resolve(),
        orderQuoteService: OrderQuoteServiceAPI = resolve(),
        orderCreationService: OrderCreationServiceAPI = resolve(),
        linkedBanksService: LinkedBanksServiceAPI = resolve()
    ) {
        self.paymentAccountService = paymentAccountService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
        self.linkedBanksService = linkedBanksService
    }

    /// 1. Fetch the payment account matching the order currency and append it to the checkout data
    /// 2. Fetch the quote and append it to the result.
    /// The order must be created beforehand and present in the checkout data.
    func prepare(using checkoutData: CheckoutData, action: Order.Action) -> InteractionData {
        guard let fiat = checkoutData.fiatValue else {
            return Single.error(InteractionError.unsupportedQuoteParameters)
        }
        guard let crypto = checkoutData.cryptoValue else {
            return Single.error(InteractionError.unsupportedQuoteParameters)
        }
        let quote = orderQuoteService
            .getQuote(
                for: action,
                cryptoCurrency: crypto.currencyType,
                fiatValue: fiat
            )

        let finalCheckoutData: Single<CheckoutData>
        if checkoutData.order.paymentMethod.isBankAccount {
            finalCheckoutData = paymentAccountService
                .paymentAccount(for: fiat.currencyType)
                .map { checkoutData.checkoutData(byAppending: $0) }
        } else if checkoutData.order.paymentMethod.isBankTransfer, let authData = checkoutData.order.authorizationData {
            finalCheckoutData = linkedBanksService
                .linkedBank(for: authData.paymentMethodId)
                .map { data -> CheckoutData in
                    guard let data = data else {
                        return checkoutData
                    }
                    return checkoutData.checkoutData(byAppending: data)
                }
        } else {
            finalCheckoutData = Single.just(checkoutData)
        }

        return Single
            .zip(
                quote,
                finalCheckoutData
            )
            .map { (payload: (quote: Quote, checkoutData: CheckoutData)) in
                let interactionData = CheckoutInteractionData(
                    time: payload.quote.time,
                    fee: payload.checkoutData.order.fee ?? MoneyValue(fiatValue: payload.quote.fee),
                    amount: MoneyValue(cryptoValue: payload.quote.estimatedAmount),
                    exchangeRate: MoneyValue(fiatValue: payload.quote.rate),
                    card: nil,
                    bankTransferData: payload.checkoutData.linkedBankData,
                    orderId: payload.checkoutData.order.identifier,
                    paymentMethod: checkoutData.order.paymentMethod
                )
                return (interactionData, payload.checkoutData)
            }
    }

    func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData> {
        guard order.paymentMethod.isFunds || order.isPendingDepositBankWire else {
            fatalError(InteractionError.orderIsNotPendingDepositBankTransfer.localizedDescription)
        }

        // order was confirmed - just fetch the details
        guard let fee = order.fee else {
            fatalError(InteractionError.missingOrderFee.localizedDescription)
        }

        return .just(
            CheckoutInteractionData(
                time: order.creationDate,
                fee: fee,
                amount: order.outputValue,
                exchangeRate: nil,
                card: nil,
                bankTransferData: nil,
                orderId: order.identifier,
                paymentMethod: order.paymentMethod
            )
        )
    }
}
