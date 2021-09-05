// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import ToolKit

struct HDPrivateKey: Equatable {

    var xpriv: String? {
        unimplemented()
    }

    var xpub: String {
        unimplemented()
    }

    var publicKey: HDPublicKey {
        unimplemented()
    }

    init(seed: Seed, network: Network = .main(Bitcoin.self)) throws {
        unimplemented()
    }

    func derive(at path: HDKeyPath) -> Result<HDPrivateKey, HDWalletKitError> {
        Result { unimplemented() }
            .mapError { HDWalletKitError.libWallyError($0) }
            .map { unimplemented() }
    }

    func derive(at path: HDKeyPath) throws -> HDPrivateKey {
        try derive(at: path).get()
    }

    static func == (lhs: HDPrivateKey, rhs: HDPrivateKey) -> Bool {
        lhs.xpriv == rhs.xpriv
            && lhs.xpub == rhs.xpub
    }
}

extension HDPrivateKey {
    static func from(seed: Seed, network: Network = .main(Bitcoin.self)) -> Result<HDPrivateKey, HDWalletKitError> {
        Result { try HDPrivateKey(seed: seed, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }
}
