// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct FastlinkConfiguration {
    public let config: String?
}

public struct BankLinkageData {
    public enum Partner {
        case yodlee
        case yapily
    }

    public let token: String?
    public let fastlinkUrl: String?
    public let fastlinkParams: FastlinkConfiguration
    public let partner: Partner
    public let id: String

    init?(from response: CreateBankLinkageResponse) {
        guard let attributes = response.attributes else {
            return nil
        }
        token = attributes.token
        fastlinkUrl = attributes.fastlinkUrl
        fastlinkParams = FastlinkConfiguration(config: attributes.fastlinkParams?.configName)
        partner = Partner(from: response.partner)
        id = response.id
    }
}

extension BankLinkageData.Partner {
    init(from response: BankLinkagePartner) {
        switch response {
        case .yodlee:
            self = .yodlee
        case .yapily:
            self = .yapily
        }
    }

    public var title: String {
        switch self {
        case .yodlee:
            return "Yodlee"
        case .yapily:
            return "Yapily"
        }
    }
}
