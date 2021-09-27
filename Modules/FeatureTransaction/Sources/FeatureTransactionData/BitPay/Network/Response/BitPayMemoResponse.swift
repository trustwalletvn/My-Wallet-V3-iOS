// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

struct BitPayMemoResponse: Decodable {
    let memo: String
}

extension BitPayMemo {

    init(response: BitPayMemoResponse) {
        self.init(memo: response.memo)
    }
}
