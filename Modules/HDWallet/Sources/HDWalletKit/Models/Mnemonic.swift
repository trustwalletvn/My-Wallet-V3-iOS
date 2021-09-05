// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import ToolKit

struct Passphrase: LosslessStringConvertible, RawRepresentable {

    var description: String {
        rawValue
    }

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init?(_ description: String) {
        rawValue = description
    }
}

struct Words {

    let value: [String]

    init(words: [String]) throws {
        unimplemented()
        // guard BIP39Mnemonic(words) != nil else {
        //     throw HDWalletKitError.unknown
        // }
        // self.value = words
    }

    init(words: String) throws {
        try self.init(words: words.components(separatedBy: " "))
    }
}

struct Mnemonic {

    enum Strength: Int {
        case normal = 128
        case high = 256
    }

    var seed: Seed? {
        unimplemented()
        // let bip39seed = libWallyMnemonic.seedHex(passphrase?.rawValue)
        // let data = Data(hexValue: bip39seed.description)
        // return Seed(data: data)
    }

    private let words: Words
    private let passphrase: Passphrase?

    init(entropy: Entropy, passphrase: Passphrase? = nil) throws {
        unimplemented()
        // guard
        //     let entropy = BIP39Entropy(entropy.hexValue),
        //     let libWallyMnemonic = BIP39Mnemonic(entropy)
        // else {
        //     throw HDWalletKitError.unknown
        // }
        // let words = try Words(words: libWallyMnemonic.words)
        // self.words = words
        // self.passphrase = passphrase
        // self.libWallyMnemonic = libWallyMnemonic
    }

    init(words: Words, passphrase: Passphrase? = nil) throws {
        unimplemented()
        // guard let libWallyMnemonic = BIP39Mnemonic(words.value) else {
        //     throw HDWalletKitError.unknown
        // }
        // self.words = words
        // self.passphrase = passphrase
        // self.libWallyMnemonic = libWallyMnemonic
    }

    // TODO:
    // * This needs to be rewritten with a proper source of entropy
    @available(*, deprecated, message: "Don't use this! this is insecure")
    static func create(passphrase: Passphrase? = nil, strength: Strength = .normal, language: WordList = WordList.default) throws -> Mnemonic {
        let entropy = Entropy.create(size: strength.rawValue)
        return try Mnemonic(entropy: entropy, passphrase: passphrase)
    }
}
