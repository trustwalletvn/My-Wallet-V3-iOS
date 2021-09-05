// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import Foundation

struct HDPublicKey: HexRepresentable {

    let data: Data

    init(data: Data) {
        self.data = data
    }
}
