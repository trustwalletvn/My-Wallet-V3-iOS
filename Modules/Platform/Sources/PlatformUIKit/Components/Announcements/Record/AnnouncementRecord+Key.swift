// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

extension AnnouncementRecord {

    /// An key used to register this Announcement history
    /// All keys must be prefixed by `"announcement-"`
    public enum Key {

        // MARK: - Persistent

        case sddUsersFirstBuy
        case walletIntro
        case verifyEmail
        case blockstackAirdropRegisteredMini
        case simpleBuyPendingTransaction
        case simpleBuyKYCIncomplete

        // MARK: - Periodic

        case backupFunds
        case twoFA
        case buyBitcoin
        case transferBitcoin
        case kycAirdrop
        case newSwap

        // MARK: - One Time

        case blockstackAirdropReceived
        case identityVerification
        case exchange
        case bitpay
        case resubmitDocuments
        case fiatFundsKYC
        case fiatFundsNoKYC
        case cloudBackup
        case interestFunds
        case newAsset(code: String)

        var string: String {
            let prefix = "announcement-"
            let key: String
            switch self {
            case .sddUsersFirstBuy:
                key = "cache-sdd-users-buy"
            case .walletIntro:
                key = "cache-wallet-intro"
            case .verifyEmail:
                key = "cache-email-verification"
            case .blockstackAirdropRegisteredMini:
                key = "cache-stx-registered-airdrop-mini"
            case .simpleBuyPendingTransaction:
                key = "simple-buy-pending-transaction"
            case .simpleBuyKYCIncomplete:
                key = "simple-buy-kyc-incomplete"

            // MARK: - Periodic

            case .backupFunds:
                key = "cache-backup-funds"
            case .twoFA:
                key = "cache-2fa"
            case .buyBitcoin:
                key = "cache-buy-btc"
            case .transferBitcoin:
                key = "cache-transfer-btc"
            case .kycAirdrop:
                key = "cache-kyc-airdrop"
            case .newSwap:
                key = "cache-new-swap"

            // MARK: - One Time

            case .blockstackAirdropReceived:
                key = "cache-kyc-stx-airdrop-received"
            case .identityVerification:
                key = "cache-identity-verification"
            case .exchange:
                key = "cache-pit"
            case .bitpay:
                key = "cache-bitpay"
            case .resubmitDocuments:
                key = "cache-resubmit-documents"
            case .fiatFundsKYC:
                key = "cache-fiat-funds-kyc"
            case .fiatFundsNoKYC:
                key = "cache-fiat-funds-no-kyc"
            case .cloudBackup:
                key = "cache-cloud-backup"
            case .interestFunds:
                key = "cache-interest-funds"
            case .newAsset(let code):
                key = "cache-new-asset-\(code)"
            }

            return prefix + key
        }
    }
}
