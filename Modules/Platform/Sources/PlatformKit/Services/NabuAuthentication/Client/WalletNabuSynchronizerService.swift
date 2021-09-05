// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import RxCombine
import RxSwift
import ToolKit

enum WalletNabuSynchronizerServiceError: Error {
    case failedToRetrieveToken
    case failedToUpdateWalletInfo
}

/// Protocol definition for a component that can synchronize state between the wallet
/// and Nabu.
public protocol WalletNabuSynchronizerServiceAPI {
    func sync() -> Completable
}

final class WalletNabuSynchronizerService: WalletNabuSynchronizerServiceAPI {

    private var syncPublisher: AnyPublisher<EmptyNetworkResponse, WalletNabuSynchronizerServiceError> {
        let updateUserInformationClient = self.updateUserInformationClient
        return jwtService.token
            .replaceError(with: .failedToRetrieveToken)
            .flatMap { [updateUserInformationClient] jwtToken -> AnyPublisher<EmptyNetworkResponse, WalletNabuSynchronizerServiceError> in
                updateUserInformationClient
                    .updateWalletInfo(jwtToken: jwtToken)
                    .replaceError(with: .failedToUpdateWalletInfo)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private let jwtService: JWTServiceAPI
    private let updateUserInformationClient: UpdateWalletInformationClientAPI

    init(
        jwtService: JWTServiceAPI = resolve(),
        updateUserInformationClient: UpdateWalletInformationClientAPI = resolve()
    ) {
        self.jwtService = jwtService
        self.updateUserInformationClient = updateUserInformationClient
    }

    func sync() -> Completable {
        syncPublisher
            .asObservable()
            .ignoreElements()
    }
}
