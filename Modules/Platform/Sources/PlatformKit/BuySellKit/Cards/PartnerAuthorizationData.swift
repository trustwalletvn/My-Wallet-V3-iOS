// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PartnerAuthorizationData {

    public static var exitLink = "https://www.blockchain.com/"

    /// Required authorization type
    public enum State {
        public struct Urls {
            public let paymentLink: URL
            public let exitLink: URL

            init(paymentLink: URL) {
                self.paymentLink = paymentLink
                exitLink = URL(string: PartnerAuthorizationData.exitLink)!
            }
        }

        /// Requires user user authorization by visiting the associated link
        case required(Urls)

        /// Confirmed authorization
        case confirmed

        /// Authorized to proceed - no auth required
        case none

        var isRequired: Bool {
            switch self {
            case .required:
                return true
            case .confirmed, .none:
                return false
            }
        }

        var isConfirmed: Bool {
            switch self {
            case .confirmed:
                return true
            case .required, .none:
                return false
            }
        }
    }

    /// The type of required authorization
    public let state: State

    /// The payment method id that needs to be authorized
    public let paymentMethodId: String
}

extension PartnerAuthorizationData {
    init?(orderPayloadResponse: OrderPayload.Response) {
        guard let paymentMethodId = orderPayloadResponse.paymentMethodId else {
            return nil
        }
        self.paymentMethodId = paymentMethodId

        if let everypay = orderPayloadResponse.attributes?.everypay {
            switch everypay.paymentState {
            case .waitingFor3DS:
                let url = URL(string: everypay.paymentLink)!
                state = .required(.init(paymentLink: url))
            case .confirmed3DS:
                state = .confirmed
            }
        } else {
            state = .none
        }
    }
}
