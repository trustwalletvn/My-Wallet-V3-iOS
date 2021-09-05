// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public final class CardOrderCheckoutInteractor {

    private enum InteractionError: Error {
        case orderStateMismatch(is3DSConfirmedCardOrder: Bool, isPending3DSCardOrder: Bool)
        case missingFee
        case missingPaymentMethodId
        case missingPrice
        case outputMustBeCrypto(CurrencyType)
        case inputMustBeFiat(MoneyValue)

        var localizedDescription: String {
            switch self {
            case .orderStateMismatch(is3DSConfirmedCardOrder: let is3DSConfirmedCardOrder, isPending3DSCardOrder: let isPending3DSCardOrder):
                // swiftlint:disable line_length
                return "Order state mismatch - got is3DSConfirmedCardOrder: \(is3DSConfirmedCardOrder), isPending3DSCardOrder: \(isPending3DSCardOrder)"
            case .missingFee:
                return "Order fee is missing"
            case .missingPaymentMethodId:
                return "Order payment method ID is missing"
            case .missingPrice:
                return "Order price is missing"
            case .outputMustBeCrypto(let type):
                return "Order must be for crypto not: \(type)"
            case .inputMustBeFiat(let value):
                return "Order input must be in fiat, not: \(value)"
            }
        }
    }

    private let cardListService: CardListServiceAPI
    private let orderQuoteService: OrderQuoteServiceAPI
    private let orderCreationService: OrderCreationServiceAPI

    public init(
        cardListService: CardListServiceAPI = resolve(),
        orderQuoteService: OrderQuoteServiceAPI = resolve(),
        orderCreationService: OrderCreationServiceAPI = resolve()
    ) {
        self.cardListService = cardListService
        self.orderQuoteService = orderQuoteService
        self.orderCreationService = orderCreationService
    }

    /// Fetch the quote and append it to the result along with the checkout data.
    func prepare(using checkoutData: CheckoutData) -> Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)> {
        guard let paymentMethodId = checkoutData.order.paymentMethodId else {
            fatalError(InteractionError.missingPaymentMethodId.localizedDescription)
        }
        /// `CardOrderCheckoutInteractor` is for purchasing `Crypto` and not `Fiat`.
        guard let crypto = checkoutData.order.outputValue.cryptoValue else {
            return Single.error(InteractionError.outputMustBeCrypto(checkoutData.outputCurrency))
        }
        guard let fiat = checkoutData.order.inputValue.fiatValue else {
            return Single.error(InteractionError.inputMustBeFiat(checkoutData.order.inputValue))
        }
        return orderQuoteService
            .getQuote(
                for: .buy,
                cryptoCurrency: crypto.currencyType,
                fiatValue: fiat
            )
            .flatMap(weak: self) { (self, quote) in
                self.cardListService
                    .card(by: paymentMethodId)
                    .map { card in
                        let interactionData = CheckoutInteractionData(
                            time: quote.time,
                            fee: checkoutData.order.fee ?? MoneyValue(fiatValue: quote.fee),
                            amount: MoneyValue(cryptoValue: quote.estimatedAmount),
                            exchangeRate: MoneyValue(fiatValue: quote.rate),
                            card: card,
                            bankTransferData: nil,
                            orderId: checkoutData.order.identifier,
                            paymentMethod: checkoutData.order.paymentMethod
                        )
                        return (interactionData, checkoutData)
                    }
            }
    }

    func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData> {
        /// 3DS was confirmed on this order - just fetch the details
        guard order.is3DSConfirmedCardOrder || order.isPending3DSCardOrder else {
            fatalError(
                InteractionError.orderStateMismatch(
                    is3DSConfirmedCardOrder: order.is3DSConfirmedCardOrder,
                    isPending3DSCardOrder: order.isPending3DSCardOrder
                ).localizedDescription
            )
        }

        guard let paymentMethodId = order.paymentMethodId else {
            fatalError(InteractionError.missingPaymentMethodId.localizedDescription)
        }

        guard let fee = order.fee else {
            fatalError(InteractionError.missingFee.localizedDescription)
        }

        guard let price = order.price else {
            fatalError(InteractionError.missingPrice.localizedDescription)
        }

        return cardListService
            .card(by: paymentMethodId)
            .map { card in
                CheckoutInteractionData(
                    time: order.creationDate,
                    fee: fee,
                    amount: order.outputValue,
                    exchangeRate: price,
                    card: card,
                    bankTransferData: nil,
                    orderId: order.identifier,
                    paymentMethod: order.paymentMethod
                )
            }
    }
}
