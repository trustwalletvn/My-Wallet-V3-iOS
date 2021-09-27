// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import WalletCore

struct EthereumAddressValidator {

    /// Converts address to checksum address
    static func toChecksumAddress(_ address: String) -> String? {
        let address = address.lowercased().withoutHex
        guard let data = address.data(using: .ascii) else { return nil }
        let hash = WalletCore.Hash.keccak256(data: data).hexValue
        var ret = "0x"
        for (i, char) in address.enumerated() {
            let startIdx = hash.index(hash.startIndex, offsetBy: i)
            let endIdx = hash.index(hash.startIndex, offsetBy: i + 1)
            let hashChar = String(hash[startIdx..<endIdx])
            let c = String(char)
            guard let int = Int(hashChar, radix: 16) else { return nil }
            if int >= 8 {
                ret += c.uppercased()
            } else {
                ret += c
            }
        }
        return ret
    }

    // Check that the address only contains alphanumerics
    private static func isAlphanumericOnly(_ address: String) -> Bool {
        address.withoutHex.isAlphanumeric
    }

    /// Checks if address size is 20 bytes long.
    private static func hasCorrectLength(_ address: String) -> Bool {
        Data(hexValue: address.withoutHex).count == 20
    }

    static func validate(address: String) throws {
        // Check that the address only contains alphanumerics
        guard Self.isAlphanumericOnly(address) else {
            throw AddressValidationError.containsInvalidCharacters
        }

        // Check that the normalised address is exactly 20 bytes long
        guard Self.hasCorrectLength(address) else {
            throw AddressValidationError.invalidLength
        }
    }

    static func isValid(address: String) -> Bool {
        isAlphanumericOnly(address) && hasCorrectLength(address)
    }
}
