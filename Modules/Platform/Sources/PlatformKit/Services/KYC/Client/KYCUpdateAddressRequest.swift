// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Model for updating the user's address during KYC
public struct KYCUpdateAddressRequest: Codable {
    let address: UserAddress

    private enum CodingKeys: String, CodingKey {
        case address
    }

    init(address: UserAddress) {
        self.address = address
    }
}
