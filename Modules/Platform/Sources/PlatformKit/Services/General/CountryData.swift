// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct CountryData: Decodable {
    public let code: String
    public let name: String
    public let regions: [String]
    public let scopes: [String]?
    public let states: [String]

    public init(code: String, name: String, regions: [String], scopes: [String]?, states: [String]) {
        self.code = code
        self.name = name
        self.regions = regions
        self.scopes = scopes
        self.states = states
    }

    /// Returns a boolean indicating if this country is supported by Blockchain's native KYC
    public var isKycSupported: Bool {
        scopes?.contains(where: { $0.lowercased() == "kyc" }) ?? false
    }
}
