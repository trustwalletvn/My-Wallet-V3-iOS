// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct HDWallet {

    var privateKey: HDPrivateKey {
        keychain.privateKey
    }

    var publicKey: HDPublicKey {
        keychain.privateKey.publicKey
    }

    private let keychain: HDKeychain

    init(keychain: HDKeychain) {
        self.keychain = keychain
    }

    init(mnemonic: Mnemonic, network: Network) throws {
        let keychain: HDKeychain
        do {
            keychain = try HDKeychain(mnemonic: mnemonic, network: network)
        } catch {
            throw HDWalletKitError.libWallyError(error)
        }
        self.keychain = keychain
    }

    func privateKey(at path: HDKeyPath) throws -> HDPrivateKey {
        try keychain.derivedKey(path: path)
    }

    func publicKey(at path: HDKeyPath) throws -> HDPublicKey {
        try privateKey(at: path).publicKey
    }
}

extension HDWallet {

    static func from(mnemonic: Mnemonic, network: Network) -> Result<HDWallet, HDWalletKitError> {
        Result { try HDWallet(mnemonic: mnemonic, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }
}

extension HDWallet {

    func privateKey(at path: HDKeyPath) -> Result<HDPrivateKey, HDWalletKitError> {
        Result { try privateKey(at: path) }
            .mapError { $0 as! HDWalletKitError }
    }

    func publicKey(at path: HDKeyPath) -> Result<HDPublicKey, HDWalletKitError> {
        Result { try publicKey(at: path) }
            .mapError { $0 as! HDWalletKitError }
    }
}
