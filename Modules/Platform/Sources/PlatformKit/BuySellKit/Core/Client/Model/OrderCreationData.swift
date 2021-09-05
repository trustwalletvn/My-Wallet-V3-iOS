// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum Order {
    public enum Action: String, Codable {
        case buy = "BUY"
        case sell = "SELL"
    }
}

enum OrderPayload {

    enum CreateActionType: String, Encodable {
        case confirm
        case pending
    }

    struct ConfirmOrder: Encodable {

        enum Partner {
            case everyPay(customerUrl: String)
            case bank
            case funds
        }

        struct Attributes: Encodable {
            struct EveryPay: Encodable {
                let customerUrl: String
            }

            let everypay: EveryPay?
        }

        let paymentMethodId: String?
        let action: CreateActionType
        let attributes: Attributes?

        init(partner: Partner, action: CreateActionType, paymentMethodId: String?) {
            switch partner {
            case .everyPay(customerUrl: let url):
                attributes = Attributes(everypay: .init(customerUrl: url))
            case .bank, .funds:
                attributes = nil
            }
            self.action = action
            self.paymentMethodId = paymentMethodId
        }
    }

    struct Request: Encodable {
        struct Input: Encodable {
            let symbol: String
            let amount: String
        }

        struct Output: Encodable {
            let symbol: String
        }

        let pair: String
        let action: Order.Action
        let input: Input
        let output: Output
        let paymentType: PaymentMethodPayloadType?
        let paymentMethodId: String?

        init(
            action: Order.Action,
            fiatValue: FiatValue,
            fiatCurrency: FiatCurrency,
            cryptoValue: CryptoValue,
            paymentType: PaymentMethod.MethodType? = nil,
            paymentMethodId: String? = nil
        ) {
            self.action = action
            self.paymentMethodId = paymentMethodId
            self.paymentType = paymentType?.rawType
            switch action {
            case .buy:
                input = Input(
                    symbol: fiatValue.currencyCode,
                    amount: fiatValue.minorString
                )
                output = Output(symbol: cryptoValue.currency.code)
                pair = "\(output.symbol)-\(input.symbol)"
            case .sell:
                input = Input(
                    symbol: cryptoValue.code,
                    amount: "\(cryptoValue.amount)"
                )
                output = Output(symbol: fiatCurrency.code)
                pair = "\(input.symbol)-\(output.symbol)"
            }
        }
    }

    struct Response: Decodable {
        enum Side: String, Decodable {
            case buy = "BUY"
            case sell = "SELL"
        }

        struct Attributes: Decodable {
            struct EveryPay: Decodable {
                enum PaymentState: String, Decodable {
                    case waitingFor3DS = "WAITING_FOR_3DS_RESPONSE"
                    case confirmed3DS = "CONFIRMED_3DS"
                }

                let paymentLink: String
                let paymentState: PaymentState
            }

            let everypay: EveryPay?
        }

        let state: String

        let id: String

        let inputCurrency: String
        let inputQuantity: String

        let outputCurrency: String
        let outputQuantity: String

        let updatedAt: String
        let expiresAt: String

        let price: String?
        let fee: String?

        let paymentType: String
        let paymentMethodId: String?
        let side: Side
        let attributes: Attributes?
    }
}

extension OrderPayload.Response.Attributes.EveryPay {

    private enum CodingKeys: String, CodingKey {
        case paymentLink
        case paymentState
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentLink = try container.decode(String.self, forKey: .paymentLink)
        let paymentState = try container.decode(String.self, forKey: .paymentState)
        self.paymentState = PaymentState(rawValue: paymentState) ?? .confirmed3DS
    }
}
