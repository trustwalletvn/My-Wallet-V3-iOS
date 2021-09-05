// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A Secure Channel connection details that come embedded in a push notification.
public struct SecureChannelConnectionDetails {
    /// The IP from which the connection was initiated.
    public let originIP: String
    /// The Country from which the connection was initiated.
    public let originCountry: String
    /// The Browser from which the connection was initiated.
    public let originBrowser: String
    /// The browser Public Key hash.
    let pubkeyHash: String
    /// The encrypted message.
    let messageRawEncrypted: String

    public init?(_ userInfo: [AnyHashable: Any]) {
        guard
            let pubkeyHash = userInfo["fcm_data_pubkeyhash"] as? String,
            let messageRawEncrypted = userInfo["fcm_data_message"] as? String,
            let originIP = userInfo["origin_ip"] as? String,
            let originCountry = userInfo["origin_country"] as? String,
            let originBrowser = userInfo["origin_browser"] as? String
        else { return nil }
        self.pubkeyHash = pubkeyHash
        self.messageRawEncrypted = messageRawEncrypted
        self.originIP = originIP
        self.originCountry = originCountry
        self.originBrowser = originBrowser
    }
}
