// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum WalletInfoError: Error {
    case failToDecodeBase64Component
    case failToDecodeToWalletInfo(Error)
}

public struct WalletInfo: Codable, Equatable {

    // MARK: - Type

    private enum CodingKeys: String, CodingKey {
        case guid
        case email
        case emailCode = "email_code"
        case isMobileSetup = "is_mobile_setup"
        case hasCloudBackup = "has_cloud_backup"
    }

    // MARK: - Properties

    public static let empty = WalletInfo(
        guid: "",
        email: "",
        emailCode: "",
        isMobileSetup: false,
        hasCloudBackup: false
    )

    public let guid: String
    public let email: String
    public let emailCode: String
    public let isMobileSetup: Bool?
    public let hasCloudBackup: Bool?

    // MARK: - Setup

    public init(
        guid: String,
        email: String,
        emailCode: String,
        isMobileSetup: Bool?,
        hasCloudBackup: Bool?
    ) {
        self.guid = guid
        self.email = email
        self.emailCode = emailCode
        self.isMobileSetup = isMobileSetup
        self.hasCloudBackup = hasCloudBackup
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guid = try values.decode(String.self, forKey: .guid)
        email = try values.decode(String.self, forKey: .email)
        emailCode = try values.decode(String.self, forKey: .emailCode)
        isMobileSetup = try values.decodeIfPresent(Bool.self, forKey: .isMobileSetup)
        hasCloudBackup = try values.decodeIfPresent(Bool.self, forKey: .hasCloudBackup)
    }
}
