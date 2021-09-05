// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

public protocol TwoFAWalletClientAPI: AnyObject {
    func payload(
        guid: String,
        sessionToken: String,
        code: String
    ) -> AnyPublisher<WalletPayloadWrapper, TwoFAWalletClient.ClientError>
}
