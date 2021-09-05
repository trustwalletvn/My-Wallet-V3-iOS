// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Represents an state (geographical and/or political region)
public struct KYCState: Codable {
    public let code: String
    public let countryCode: String
    public let name: String
    public let scopes: [String]?

    /// Returns a boolean indicating if this state is supported by Blockchain's native KYC
    public var isKycSupported: Bool {
        scopes?.contains(where: { $0.lowercased() == "kyc" }) ?? false
    }
}
