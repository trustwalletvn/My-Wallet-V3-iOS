// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// PaymentAccountPatcher goal is to 'fix' PaymentAccount objects that have missing fields.
/// For Simple Buy implementation (IOS-2833), it patches EUR accounts that are missing bank country with
/// a hardcoded country name and a given recipient name
final class PaymentAccountPatcher {
    static let targetBankCode = "LHVBEE22"
    static let targetBankCountry = "Estonia"

    func patch(_ account: PaymentAccountDescribing, recipientName: String) -> PaymentAccountDescribing {
        if account.currency == .EUR {
            return patchEuroPaymentAccount(account, recipientName: recipientName)
        }
        return account
    }

    /// Patch an PaymentAccountEUR if needed
    private func patchEuroPaymentAccount(_ account: PaymentAccountDescribing, recipientName: String) -> PaymentAccountDescribing {
        /// Account must be a PaymentAccountEUR. If not, don't patch it.
        guard let eurAccount = account as? PaymentAccountEUR else {
            return account
        }

        /// Account must have an know bank code, and an empty bank country. If not, don't patch it.
        guard eurAccount.bankCode == Self.targetBankCode,
              eurAccount.bankCountry.isEmpty
        else {
            return account
        }

        /// Account matches the criteria, update it with hardcoded bankCountry and given recipientName.
        return eurAccount
            .with(bankCountry: Self.targetBankCountry)
            .with(recipientName: recipientName)
    }
}
