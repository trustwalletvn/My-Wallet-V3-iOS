// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public struct LinkedBankData {
    public enum Partner: String {
        case yodlee = "YODLEE"
        case yapily = "YAPILY"
        case none = "NONE"
    }

    public struct Account {
        public let name: String
        public let type: LinkedBankAccountType
        public let bankName: String
        public let number: String

        init(response: LinkedBankResponse) {
            let accountNumber = (response.accountNumber?.replacingOccurrences(of: "x", with: "") ?? "")
            name = (response.accountName ?? response.name)
            type = LinkedBankAccountType(from: response.bankAccountType)
            bankName = response.name
            number = accountNumber
        }
    }

    public enum LinkageError {
        case alreadyLinked
        case unsuportedAccount
        case namesMismatched
        case timeout
        case unknown
    }

    public let currency: FiatCurrency
    public let identifier: String
    public let account: Account?
    let state: LinkedBankResponse.State
    public let error: LinkageError?
    public let paymentMethodType: PaymentMethodPayloadType
    public let partner: Partner

    public var topLimit: FiatValue

    public var isActive: Bool {
        state == .active
    }

    init?(response: LinkedBankResponse) {
        identifier = response.id
        account = Account(response: response)
        state = response.state
        error = LinkageError(from: response.error)
        paymentMethodType = response.isBankTransferAccount ? .bankTransfer : .bankAccount
        guard let partner = Partner(rawValue: response.partner) else {
            return nil
        }
        self.partner = partner
        guard let currency = FiatCurrency(code: response.currency) else {
            return nil
        }
        self.currency = currency
        topLimit = .zero(currency: .USD)
    }
}

extension LinkedBankData.LinkageError {
    init?(from error: LinkedBankResponse.Error?) {
        guard let error = error else { return nil }
        switch error {
        case .alreadyLinked:
            self = .alreadyLinked
        case .namesMissmatched:
            self = .namesMismatched
        case .unsuportedAccount:
            self = .unsuportedAccount
        default:
            self = .unknown
        }
    }
}

extension LinkedBankData: Equatable {
    public static func == (lhs: LinkedBankData, rhs: LinkedBankData) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
