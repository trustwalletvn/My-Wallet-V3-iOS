// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Data {

    /// Return a random Data object of the given lenght.
    /// - parameter count: Length of the data object to be created. It must be greater than 0.
    public static func randomData(count: Int) -> Data? {
        guard count > 0 else {
            fatalError("'count' is '\(count)' when it should be greater 0")
        }
        var bytes = [UInt8](repeating: 0, count: count)
        let status = bytes.withUnsafeMutableBytes { bytesPtr in
            SecRandomCopyBytes(kSecRandomDefault, count, bytesPtr.baseAddress!)
        }
        guard status == errSecSuccess else {
            fatalError("\(#function) status '\(status)' not errSecSuccess.")
        }
        return Data(bytes)
    }
}
