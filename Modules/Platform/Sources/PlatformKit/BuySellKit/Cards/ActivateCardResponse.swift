// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct ActivateCardResponse: Decodable {

    public enum Partner {
        public struct EveryPayData: Decodable {
            let apiUsername: String
            let mobileToken: String
            let paymentLink: String
            let paymentState: String
        }

        case everypay(EveryPayData)
        case unknown

        var isKnown: Bool {
            switch self {
            case .unknown:
                return false
            default:
                return true
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case everypay
    }

    let partner: Partner

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let data = try values.decodeIfPresent(Partner.EveryPayData.self, forKey: .everypay) {
            partner = .everypay(data)
        } else {
            partner = .unknown
        }
    }
}
