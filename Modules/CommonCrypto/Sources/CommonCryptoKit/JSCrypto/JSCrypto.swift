// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@objc public class JSCrypto: NSObject {

    @objc public class func derivePBKDF2SHA1HexString(password: String, salt: String, iterations: UInt32, keySizeBytes: UInt) -> String? {
        guard let saltData = salt.data(using: .utf8) else { return nil }
        return derivePBKDF2SHA1HexString(
            password: password,
            saltData: saltData,
            iterations: iterations,
            keySizeBytes: keySizeBytes
        )
    }

    @objc public class func derivePBKDF2SHA512HexString(password: String, salt: String, iterations: UInt32, keySizeBytes: UInt) -> String? {
        guard let saltData = salt.data(using: .utf8) else { return nil }
        return derivePBKDF2SHA512HexString(
            password: password,
            saltData: saltData,
            iterations: iterations,
            keySizeBytes: keySizeBytes
        )
    }

    @objc public class func derivePBKDF2SHA1HexString(password: String, saltData: Data, iterations: UInt32, keySizeBytes: UInt) -> String? {
        derivePBKDF2SHA1(password: password, saltData: saltData, iterations: iterations, keySizeBytes: keySizeBytes)?.hexValue
    }

    @objc public class func derivePBKDF2SHA512HexString(password: String, saltData: Data, iterations: UInt32, keySizeBytes: UInt) -> String? {
        derivePBKDF2SHA512(password: password, saltData: saltData, iterations: iterations, keySizeBytes: keySizeBytes)?.hexValue
    }

    @objc public class func derivePBKDF2SHA1(password: String, saltData: Data, iterations: UInt32, keySizeBytes: UInt) -> Data? {
        PBKDF2.derive(password: password, salt: saltData, iterations: iterations, keySizeBytes: keySizeBytes, algorithm: .sha1)
    }

    @objc public class func derivePBKDF2SHA512(password: String, saltData: Data, iterations: UInt32, keySizeBytes: UInt) -> Data? {
        PBKDF2.derive(password: password, salt: saltData, iterations: iterations, keySizeBytes: keySizeBytes, algorithm: .sha512)
    }
}
