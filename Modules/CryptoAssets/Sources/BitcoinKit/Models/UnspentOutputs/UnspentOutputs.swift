// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import BitcoinChainKit
import PlatformKit

enum UnspentOutputError: Error {
    case invalidValue
}

struct UnspentOutputs: Equatable {

    let outputs: [UnspentOutput]
}

extension UnspentOutputs {
    init(networkResponse: UnspentOutputsResponse) {
        outputs = networkResponse
            .unspent_outputs
            .compactMap { try? UnspentOutput(response: $0) }
    }
}
