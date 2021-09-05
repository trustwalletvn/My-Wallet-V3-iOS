// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// The payload for the card partner (network request / response)
public enum CardPartnerPayload {

    public enum EveryPay {

        public struct SendCardDetailsRequest: Encodable {
            public struct CardDetails: Encodable {
                private enum CodingKeys: String, CodingKey {
                    case cardNumber = "cc_number"
                    case month
                    case year
                    case cardholderName = "holder_name"
                    case cvv = "cvc"
                }

                let cardNumber: String
                let month: String
                let year: String
                let cardholderName: String
                let cvv: String
            }

            private enum CodingKeys: String, CodingKey {
                case cardDetails = "cc_details"
                case apiUserName = "api_username"
                case tokenConsented = "token_consented"
                case nonce
                case timestamp
            }

            let apiUserName: String
            let nonce: String
            let timestamp: String
            let cardDetails: CardDetails
            let tokenConsented = true
        }

        public struct CardDetailsResponse: Decodable {

            enum Status: String, Decodable {
                case failed
                case authorized
                case settled
                case waitingForBav = "waiting_for_bav"
                case waitingFor3DResponse = "waiting_for_3ds_response"
            }

            private enum CodingKeys: String, CodingKey {
                case error = "processing_errors"
                case status = "payment_state"
            }

            let status: Status
            let error: String?
        }
    }
}
