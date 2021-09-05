// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain
import PlatformKit

/// Contains any needed remotely fetched data before displaying announcements.
struct AnnouncementPreliminaryData {

    /// Announcement Asset
    let announcementAsset: CryptoCurrency?

    /// The nabu user
    let user: NabuUser

    /// User tiers information
    let tiers: KYC.UserTiers

    /// User Simplified Due Diligence Eligibility
    let isSDDEligible: Bool

    let hasLinkedBanks: Bool

    let country: CountryData?

    /// The authentication type (2FA / standard)
    let authenticatorType: WalletAuthenticatorType

    var hasLinkedExchangeAccount: Bool {
        user.hasLinkedExchangeAccount
    }

    var isKycSupported: Bool {
        country?.isKycSupported ?? false
    }

    var hasTwoFA: Bool {
        authenticatorType != .standard
    }

    var hasIncompleteBuyFlow: Bool {
        simpleBuyEventCache[.hasShownBuyScreen] && isSimpleBuyAvailable
    }

    let isSimpleBuyEligible: Bool

    let pendingOrderDetails: OrderDetails?

    /// Whether the user has a wallet balance in any account.
    let hasAnyWalletBalance: Bool

    private let isSimpleBuyAvailable: Bool
    private let simpleBuyEventCache: EventCache

    init(
        user: NabuUser,
        tiers: KYC.UserTiers,
        isSDDEligible: Bool,
        hasLinkedBanks: Bool,
        countries: [CountryData],
        simpleBuyEventCache: EventCache = resolve(),
        authenticatorType: WalletAuthenticatorType,
        pendingOrderDetails: OrderDetails?,
        isSimpleBuyAvailable: Bool,
        isSimpleBuyEligible: Bool,
        hasAnyWalletBalance: Bool,
        announcementAsset: CryptoCurrency?
    ) {
        self.user = user
        self.tiers = tiers
        self.isSDDEligible = isSDDEligible
        self.hasLinkedBanks = hasLinkedBanks
        self.simpleBuyEventCache = simpleBuyEventCache
        self.authenticatorType = authenticatorType
        self.pendingOrderDetails = pendingOrderDetails
        self.isSimpleBuyAvailable = isSimpleBuyAvailable
        self.isSimpleBuyEligible = isSimpleBuyEligible
        self.hasAnyWalletBalance = hasAnyWalletBalance
        self.announcementAsset = announcementAsset
        country = countries.first { $0.code == user.address?.countryCode }
    }
}
