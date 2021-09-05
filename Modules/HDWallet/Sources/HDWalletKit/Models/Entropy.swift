// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import Foundation

struct Entropy: HexRepresentable {

    let data: Data

    init(data: Data) {
        self.data = data
    }

    // TODO:
    // * This needs to be rewritten with a proper source of entropy
    @available(*, deprecated, message: "Don't use this! this is insecure")
    static func create(size: Int) -> Entropy {
        let byteCount = size / 8
        var bytes = Data(count: byteCount)
        _ = bytes.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, byteCount, $0) }
        return Entropy(data: bytes)
    }
}
