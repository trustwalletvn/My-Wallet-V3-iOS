// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol AutoWalletPairingClientAPI: AnyObject {
    func request(guid: String) -> AnyPublisher<String, NetworkError>
}
