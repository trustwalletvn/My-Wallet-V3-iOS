// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum SecureChannel {
    enum Authorization: String, Codable {
        case loginWallet = "login_wallet"
        case handshake
    }

    struct EmptyResponse: Codable {}

    struct PairingCode: Decodable {
        let pubkey: String
        let channelId: String
        let type: Authorization
    }

    struct PairingHandshake: Encodable {
        let guid: String
        let type: Authorization = .handshake
    }

    struct LoginMessage: Encodable {
        let guid: String
        let password: String
        let sharedKey: String
        let remember: Bool = true
        let type: Authorization = .loginWallet
    }

    struct PairingResponse: Codable {
        let channelId: String
        let pubkey: String
        let success: Bool
        let message: String
    }

    struct BrowserMessage: Codable {
        let type: String
        let channelId: String
        let timestamp: UInt64
    }
}
