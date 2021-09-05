// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Struct for updating the user's personal details during KYC
public struct KYCUpdatePersonalDetailsRequest: Codable {
    public let firstName: String?
    public let lastName: String?
    public let birthday: Date?

    private enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case birthday = "dob"
    }

    public init(firstName: String?, lastName: String?, birthday: Date?) {
        self.firstName = firstName
        self.lastName = lastName
        self.birthday = birthday
    }
}
