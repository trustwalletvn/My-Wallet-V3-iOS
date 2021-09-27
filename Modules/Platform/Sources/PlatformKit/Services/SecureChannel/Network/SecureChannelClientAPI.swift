// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

enum SendSecureChannelError: Error {
    case couldNotBuildRequestBody
    case networkFailure
    case emptyCredentials
    case unknownReceiver
}

protocol SecureChannelClientAPI: AnyObject {
    func sendMessage(
        msg: SecureChannel.PairingResponse
    ) -> AnyPublisher<Void, SendSecureChannelError>

    func getIp() -> AnyPublisher<String, SendSecureChannelError>
}
