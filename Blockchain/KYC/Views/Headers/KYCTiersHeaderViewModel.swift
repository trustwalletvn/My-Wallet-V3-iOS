//
//  KYCTiersHeaderViewModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// This view model is used in `KYCTiersPageModel`. It dictates what
/// type of header this screen has and what information should be displayed
/// in said header.
enum KYCTiersHeaderViewModel {
    enum Action {
        case learnMore
        case contactSupport
    }
    typealias Amount = String
    
    /// `AmountDescription` is either a value that describes what `Swap` is
    /// or it can be informing the user that their currently being reviewed for
    /// `Tier Two`. These are the two states outlined in the comps. 
    typealias AmountDescription = String
    
    case available(Amount, AmountDescription, suppressDismissCTA: Bool)
    case availableToday(Amount, AmountDescription, suppressDismissCTA: Bool)
    case unavailable(suppressDismissCTA: Bool)
    case empty(suppressDismissCTA: Bool)
}

extension KYCTiersHeaderViewModel {
    
    var suppressDismissCTA: Bool {
        switch self {
        case .available(_, _, let value):
            return value
        case .availableToday(_, _, let value):
            return value
        case .unavailable(let value):
            return value
        case .empty(let value):
            return value
        }
    }
    
    var identifier: String {
        switch self {
        case .unavailable,
             .empty:
            return KYCCTAHeaderView.identifier
        case .available,
             .availableToday:
            return KYCAvailableFundsHeaderView.identifier
        }
    }
    
    var headerType: KYCTiersHeaderView.Type {
        switch self {
        case .unavailable,
            .empty:
            return KYCCTAHeaderView.self
        case .available,
             .availableToday:
            return KYCAvailableFundsHeaderView.self
        }
    }
    
    func estimatedHeight(for width: CGFloat, model: KYCTiersHeaderViewModel) -> CGFloat {
        return headerType.estimatedHeight(
            for: width,
            model: self
        )
    }
}

extension KYCTiersHeaderViewModel: Equatable {
    static func == (lhs: KYCTiersHeaderViewModel, rhs: KYCTiersHeaderViewModel) -> Bool {
        switch (lhs, rhs) {
        case (.available(let lhsAmount, let lhsDescription, _), .available(let rhsAmount, let rhsDescription, _)):
            return lhsAmount == rhsAmount &&
            lhsDescription == rhsDescription
        case (.availableToday(let lhsAmount, let lhsDescription, _), .availableToday(let rhsAmount, let rhsDescription, _)):
            return lhsAmount == rhsAmount &&
                lhsDescription == rhsDescription
        case (.unavailable, .unavailable):
            return true
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

extension KYCTiersHeaderViewModel {
    
    var amountVisibility: Visibility {
        switch self {
        case .available,
             .availableToday:
            return .visible
        case .unavailable,
             .empty:
            return .hidden
        }
    }
    
    var amount: String? {
        switch self {
        case .available(let value, _, _):
            return value
        case .availableToday(let value, _, _):
            return value
        case .unavailable,
             .empty:
            return nil
        }
    }
    
    var actions: [Action]? {
        switch self {
        case .available,
             .availableToday,
             .empty:
            return nil
        case .unavailable:
            return [.contactSupport, .learnMore]
        }
    }
    
    var availabilityTitle: String? {
        switch self {
        case .available:
            return LocalizationConstants.KYC.available
        case .availableToday:
            return LocalizationConstants.KYC.availableToday
        case .unavailable,
             .empty:
            return nil
        }
    }
    
    var availabilityDescription: String? {
        switch self {
        case .available(_, let description, _):
            return description
        case .availableToday(_, let description, _):
            return description
        case .unavailable,
             .empty:
            return nil
        }
    }
    
    var subtitle: String? {
        switch self {
        case .available,
             .availableToday:
            return nil
        case .unavailable:
            return LocalizationConstants.KYC.swapUnavailableDescription
        case .empty:
            return LocalizationConstants.KYC.swapAnnouncement
        }
    }
    
    var title: String? {
        switch self {
        case .available,
             .availableToday:
            return nil
        case .unavailable:
            return LocalizationConstants.KYC.swapUnavailable
        case .empty:
            return LocalizationConstants.KYC.swapTagline
        }
    }
    
}

extension KYCTiersHeaderViewModel {
    static func make(
        with tierResponse: KYCUserTiersResponse,
        status: KYCAccountStatus,
        currencySymbol: String,
        availableFunds: String?,
        suppressDismissCTA: Bool = false
        ) -> KYCTiersHeaderViewModel {
        let tiers = tierResponse.userTiers.filter({ $0.tier != .tier0 })
        guard let tier2 = tiers.filter({ $0.tier == .tier2 }).first else { return .unavailable(suppressDismissCTA: suppressDismissCTA) }
        
        switch status {
        case .none:
            return .empty(suppressDismissCTA: suppressDismissCTA)
        case .failed,
             .expired:
            return .unavailable(suppressDismissCTA: suppressDismissCTA)
        case .pending,
             .underReview:
            guard let amount = availableFunds else { return .unavailable(suppressDismissCTA: suppressDismissCTA) }
            let formatted = currencySymbol + amount
            if tier2.state == .pending || tier2.state == .rejected {
                return .available(
                    formatted, LocalizationConstants.KYC.tierTwoVerificationIsBeingReviewed,
                    suppressDismissCTA: suppressDismissCTA
                )
            }
            
            return .available(
                formatted, LocalizationConstants.KYC.swapLimitDescription,
                suppressDismissCTA: suppressDismissCTA
            )
        case .approved:
            guard let amount = availableFunds else { return .unavailable(suppressDismissCTA: suppressDismissCTA) }
            let formatted = currencySymbol + amount
            if tier2.state == .verified {
                return .availableToday(
                    formatted,
                    LocalizationConstants.KYC.swapLimitDescription,
                    suppressDismissCTA: suppressDismissCTA
                )
            }
            
            if tier2.state == .pending || tier2.state == .rejected {
                return .available(
                    formatted,
                    LocalizationConstants.KYC.tierTwoVerificationIsBeingReviewed,
                    suppressDismissCTA: suppressDismissCTA
                )
            }
            return .available(
                formatted,
                LocalizationConstants.KYC.swapLimitDescription,
                suppressDismissCTA: suppressDismissCTA
            )
        }
    }
}

extension KYCTiersHeaderViewModel {
    /// NOTE: This is for demo'ing and debugging the tiers header view
    /// As there are a few different permutations, please leave this here for now.
    static let availableToday: KYCTiersHeaderViewModel = .availableToday(
        "$25,000",
        LocalizationConstants.KYC.swapLimitDescription,
        suppressDismissCTA: true
    )
    
    static let empty: KYCTiersHeaderViewModel = .empty(
        suppressDismissCTA: true
    )
}