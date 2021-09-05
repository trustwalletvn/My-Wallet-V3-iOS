// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct BillingAddress {
    public let country: Country
    public let fullName: String
    public let addressLine1: String
    public let addressLine2: String
    public let city: String
    public let state: String
    public let postCode: String

    public init?(
        country: Country,
        fullName: String?,
        addressLine1: String?,
        addressLine2: String?,
        city: String?,
        state: String?,
        postCode: String?
    ) {
        guard let fullName = fullName,
              let addressLine1 = addressLine1,
              let city = city,
              let postCode = postCode
        else {
            return nil
        }

        // Countries that have state subdomain require `state` to be initialized
        if country.hasStatesSubdomain {
            guard let state = state else { return nil }
            self.state = state
        } else {
            self.state = ""
        }

        self.country = country
        self.fullName = fullName
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2 ?? ""
        self.postCode = postCode
        self.city = city
    }
}

// MARK: - Network Bridge

extension BillingAddress {

    init?(response: CardPayload.BillingAddress?) {
        guard let response = response else { return nil }
        guard let country = Country(code: response.country) else {
            return nil
        }
        self.country = country
        state = response.state ?? ""
        postCode = response.postCode
        city = response.city
        addressLine1 = response.line1
        addressLine2 = response.line2 ?? ""
        fullName = ""
    }

    var requestPayload: CardPayload.BillingAddress {
        CardPayload.BillingAddress(
            line1: addressLine1,
            line2: addressLine2,
            postCode: postCode,
            city: city,
            state: state,
            country: country.code
        )
    }
}

// MARK: - Privately used extensions

extension Country {
    fileprivate var hasStatesSubdomain: Bool {
        switch self {
        case .US:
            return true
        default:
            return false
        }
    }
}
