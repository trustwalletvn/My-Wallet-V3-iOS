// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum KYCDocumentType: String, CaseIterable, Codable {
    case passport = "PASSPORT"
    case driversLicense = "DRIVING_LICENCE"
    case nationalIdentityCard = "NATIONAL_IDENTITY_CARD"
    case residencePermit = "RESIDENCE_PERMIT"
}

extension KYCDocumentType {
    var description: String {
        switch self {
        case .passport:
            return LocalizationConstants.KYC.passport
        case .driversLicense:
            return LocalizationConstants.KYC.driversLicense
        case .nationalIdentityCard:
            return LocalizationConstants.KYC.nationalIdentityCard
        case .residencePermit:
            return LocalizationConstants.KYC.residencePermit
        }
    }
}
