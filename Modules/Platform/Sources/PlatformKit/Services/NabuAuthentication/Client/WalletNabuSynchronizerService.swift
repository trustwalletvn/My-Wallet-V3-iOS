// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import ToolKit

public enum WalletNabuSynchronizerServiceError: Error {
    case failedToRetrieveToken
    case failedToUpdateWalletInfo
}

/// Protocol definition for a component that can synchronize state between the wallet
/// and Nabu.
public protocol WalletNabuSynchronizerServiceAPI {
    func sync() -> AnyPublisher<Void, WalletNabuSynchronizerServiceError>
}

final class WalletNabuSynchronizerService: WalletNabuSynchronizerServiceAPI {

    // MARK: - Properties

    private let jwtService: JWTServiceAPI
    private let updateUserInformationClient: UpdateWalletInformationClientAPI

    // MARK: - Setup

    init(
        jwtService: JWTServiceAPI = resolve(),
        updateUserInformationClient: UpdateWalletInformationClientAPI = resolve()
    ) {
        self.jwtService = jwtService
        self.updateUserInformationClient = updateUserInformationClient
    }

    // MARK: - Methods

    func sync() -> AnyPublisher<Void, WalletNabuSynchronizerServiceError> {
        let updateUserInformationClient = self.updateUserInformationClient
        return jwtService.token
            .replaceError(with: .failedToRetrieveToken)
            .flatMap { [updateUserInformationClient] jwtToken
                -> AnyPublisher<Void, WalletNabuSynchronizerServiceError> in
                updateUserInformationClient
                    .updateWalletInfo(jwtToken: jwtToken)
                    .replaceError(with: .failedToUpdateWalletInfo)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
