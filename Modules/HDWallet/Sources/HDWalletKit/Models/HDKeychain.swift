// Copyright © Blockchain Luxembourg S.A. All rights reserved.

struct HDKeychain {

    let privateKey: HDPrivateKey

    init(words: String, passphrase: String? = nil, network: Network) throws {
        let words = try Words(words: words)
        try self.init(words: words, passphrase: passphrase, network: network)
    }

    init(words: [String], passphrase: String? = nil, network: Network) throws {
        let words = try Words(words: words)
        try self.init(words: words, passphrase: passphrase, network: network)
    }

    init(words: Words, passphrase: String? = nil, network: Network) throws {
        var password: Passphrase?
        if let passphrase = passphrase {
            password = Passphrase(rawValue: passphrase)
        }
        let mnemonic = try Mnemonic(words: words, passphrase: password)
        try self.init(mnemonic: mnemonic, network: network)
    }

    init(seed: Seed, network: Network) throws {
        let privateKey: HDPrivateKey
        do {
            privateKey = try HDPrivateKey(seed: seed, network: network)
        } catch {
            throw HDWalletKitError.libWallyError(error)
        }
        self.privateKey = privateKey
    }

    init(mnemonic: Mnemonic, network: Network) throws {
        guard let seed = mnemonic.seed else {
            throw HDWalletKitError.unknown
        }
        try self.init(seed: seed, network: network)
    }

    init(privateKey: HDPrivateKey) {
        self.privateKey = privateKey
    }

    func derivedKey(path: HDKeyPath) throws -> HDPrivateKey {
        try privateKey.derive(at: path)
    }
}

extension HDKeychain {

    static func from(words: String, passphrase: String? = nil, network: Network) -> Result<HDKeychain, HDWalletKitError> {
        Result { try HDKeychain(words: words, passphrase: passphrase, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }

    static func from(words: [String], passphrase: String? = nil, network: Network) -> Result<HDKeychain, HDWalletKitError> {
        Result { try HDKeychain(words: words, passphrase: passphrase, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }

    static func from(words: Words, passphrase: String? = nil, network: Network) -> Result<HDKeychain, HDWalletKitError> {
        Result { try HDKeychain(words: words, passphrase: passphrase, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }

    static func from(seed: Seed, network: Network) -> Result<HDKeychain, HDWalletKitError> {
        Result { try HDKeychain(seed: seed, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }

    static func from(mnemonic: Mnemonic, network: Network) -> Result<HDKeychain, HDWalletKitError> {
        Result { try HDKeychain(mnemonic: mnemonic, network: network) }
            .mapError { $0 as! HDWalletKitError }
    }
}
