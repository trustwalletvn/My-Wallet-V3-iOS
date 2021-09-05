// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct ExtendedKey {
    let raw: Data
    let privateKey: UInt32
    let publicKey: UInt32
    let depth: UInt8
    let fingerprint: UInt32
    let childIndex: UInt32
    let chainCode: Data
}

struct HDKey {
    let extendedKey: ExtendedKey
}
