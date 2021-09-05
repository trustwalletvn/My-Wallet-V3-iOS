// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol WalletPayloadClientAPI: AnyObject {
    /// request a wallet payload from the client which contains different data for decryption
    /// - Parameters guid: wallet guid from user
    /// - Parameters identifier: session token (password login) or sharedkey (PIN login)
    /// - Returns: A combine `Publisher` that emits a ClientResponse on success or ClientError on failure
    func payload(
        guid: String,
        identifier: WalletPayloadClient.Identifier
    ) -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadClient.ClientError>
}
