// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

enum ProductResponse: String, Codable {
    case brokerage = "BROKERAGE"
}

extension ProductType {

    init(response: ProductResponse) {
        switch response {
        case .brokerage:
            self = .brokerage
        }
    }
}
