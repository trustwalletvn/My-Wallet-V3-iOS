// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

struct KYCTierPostBody: Codable {
    let selectedTier: KYC.Tier

    private enum CodingKeys: CodingKey {
        case selectedTier
    }
}
