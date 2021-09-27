// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ERC20TransfersResponse: Decodable {
    struct Transfer: Decodable {
        let from: String
        let timestamp: String
        let to: String
        let transactionHash: String
        let value: String
    }

    let transfers: [Transfer]
}
