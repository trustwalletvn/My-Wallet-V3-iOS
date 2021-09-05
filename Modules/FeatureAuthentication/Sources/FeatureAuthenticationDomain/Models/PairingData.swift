// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PairingData {

    /// The wallet GUID
    public let guid: String

    /// The wallet encrypted shared key
    public let encryptedSharedKey: String

    public init(guid: String, encryptedSharedKey: String) {
        self.guid = guid
        self.encryptedSharedKey = encryptedSharedKey
    }
}
