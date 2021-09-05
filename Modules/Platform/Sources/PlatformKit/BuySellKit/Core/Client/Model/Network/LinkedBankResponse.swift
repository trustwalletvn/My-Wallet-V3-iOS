// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct LinkedBankResponse: Decodable {
    enum AccountType: String, Decodable {
        case savings = "SAVINGS"
        case checking = "CHECKING"
        case none = "UNKNOWN"
    }

    let id: String
    let currency: String
    let partner: String
    let bankAccountType: AccountType
    let name: String
    let accountName: String?
    let accountNumber: String?
    let routingNumber: String?
    let isBankAccount: Bool
    let isBankTransferAccount: Bool
    let state: State
    let attributes: Attributes?
    let error: Error?

    enum CodingKeys: CodingKey {
        case id
        case currency
        case partner
        case state
        case details
        case error
        case isBankAccount
        case isBankTransferAccount
        case attributes
        case bankAccountType
        case name
        case accountName
        case accountNumber
        case routingNumber
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        currency = try container.decode(String.self, forKey: .currency)
        partner = try container.decode(String.self, forKey: .partner)
        state = try container.decode(State.self, forKey: .state)
        /// The `updateBankLinkage` call in `APIClient` does not return a model that
        /// matches `LinkedBankResponse`. We can set the below properties to a default value
        /// as the caller of `updateBankLinkage` does not use any part of the `LinkedBankResponse`
        /// object except for `state`.
        isBankAccount = (try container.decodeIfPresent(Bool.self, forKey: .isBankAccount) ?? false)
        isBankTransferAccount = (try container.decodeIfPresent(Bool.self, forKey: .isBankTransferAccount) ?? false)
        name = try (container.decodeIfPresent(String.self, forKey: .name) ?? "")
        attributes = try? container.decodeIfPresent(Attributes.self, forKey: .attributes)
        error = try container.decodeIfPresent(Error.self, forKey: .error)
        let accountType = try container.decodeIfPresent(AccountType.self, forKey: .bankAccountType)
        bankAccountType = accountType ?? .none
        accountName = try container.decodeIfPresent(String.self, forKey: .accountName)
        accountNumber = try container.decodeIfPresent(String.self, forKey: .accountNumber)
        routingNumber = try container.decodeIfPresent(String.self, forKey: .routingNumber)
    }
}

extension LinkedBankResponse {
    struct Attributes: Decodable {
        let entity: String
        let media: [Media]
        let status: String
        let authorisationUrl: URL

        struct Media: Decodable {
            let source: String
            let type: String
        }
    }
}

extension LinkedBankResponse {
    public enum State: String, Codable {
        case pending = "PENDING"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    public enum Error: String, Codable {
        case alreadyLinked = "BANK_TRANSFER_ACCOUNT_ALREADY_LINKED"
        case unsuportedAccount = "BANK_TRANSFER_ACCOUNT_INFO_NOT_FOUND"
        case namesMissmatched = "BANK_TRANSFER_ACCOUNT_NAME_MISMATCH"
        case unknown = ""
    }
}

enum BankLinkagePartner: String, Decodable {
    case yodlee = "YODLEE"
    case yapily = "YAPILY"
}

struct CreateBankLinkageResponse: Decodable {
    struct LinkBankAttrsResponse: Decodable {
        let token: String?
        let fastlinkUrl: String?
        let fastlinkParams: FastlinkParameters?
    }

    let id: String
    let partner: BankLinkagePartner
    let attributes: LinkBankAttrsResponse?
}

/// The specific configuration for when requesting the webview of the partner (Yodlee/Yapily)
struct FastlinkParameters: Decodable {
    let configName: String
}
