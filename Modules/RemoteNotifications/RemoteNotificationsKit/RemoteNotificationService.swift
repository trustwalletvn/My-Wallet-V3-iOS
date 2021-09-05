// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// A service that coordinates
final class RemoteNotificationService: RemoteNotificationServicing {

    // MARK: - ServiceError

    private enum ServiceError: Error {
        case unauthorizedRemoteNotificationsPermission
    }

    // MARK: - RemoteNotificationServicing (services)

    let authorizer: RemoteNotificationAuthorizing
    let backgroundReceiver: RemoteNotificationBackgroundReceiving
    let relay: RemoteNotificationEmitting

    // MARK: - Privately used services

    private let externalService: ExternalNotificationProviding
    private let networkService: RemoteNotificationNetworkServicing
    private let sharedKeyRepository: SharedKeyRepositoryAPI
    private let guidRepository: GuidRepositoryAPI

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        authorizer: RemoteNotificationAuthorizing = resolve(),
        notificationRelay: RemoteNotificationEmitting = resolve(),
        backgroundReceiver: RemoteNotificationBackgroundReceiving = resolve(),
        externalService: ExternalNotificationProviding = resolve(),
        networkService: RemoteNotificationNetworkServicing = resolve(),
        sharedKeyRepository: SharedKeyRepositoryAPI = resolve(),
        guidRepository: GuidRepositoryAPI = resolve()
    ) {
        self.authorizer = authorizer
        self.externalService = externalService
        self.networkService = networkService
        self.sharedKeyRepository = sharedKeyRepository
        self.guidRepository = guidRepository
        relay = notificationRelay
        self.backgroundReceiver = backgroundReceiver
    }
}

// MARK: - RemoteNotificationTokenSending

extension RemoteNotificationService: RemoteNotificationTokenSending {
    func sendTokenIfNeeded() -> Single<Void> {
        authorizer.isAuthorized
            .filter { isAuthorized in
                guard isAuthorized else {
                    throw ServiceError.unauthorizedRemoteNotificationsPermission
                }
                return true
            }
            .flatMap(weak: self) { (self, _) -> Single<String> in
                self.externalService.token
            }
            .flatMap(weak: self) { (self, token) -> Single<Void> in
                self.networkService.register(
                    with: token,
                    sharedKeyProvider: self.sharedKeyRepository,
                    guidProvider: self.guidRepository
                )
            }
    }

    func sendTokenIfNeededPublisher() -> AnyPublisher<Never, Error> {
        sendTokenIfNeeded()
            .asCompletable()
            .asPublisher()
    }
}

// MARK: - RemoteNotificationDeviceTokenReceiving

extension RemoteNotificationService: RemoteNotificationDeviceTokenReceiving {
    func appDidFailToRegisterForRemoteNotifications(with error: Error) {
        Logger.shared.info("Remote Notification Registration Failed with error: \(error)")
    }

    func appDidRegisterForRemoteNotifications(with deviceToken: Data) {
        Logger.shared.info("Remote Notification Registration Succeeded")

        // FCM service must be informed about the new token
        externalService.didReceiveNewApnsToken(token: deviceToken)

        // Send the token
        sendTokenIfNeeded()
            .subscribe(
                onError: { error in
                    Logger.shared.error("Remote notification token could not be sent to the backend. received error: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
}
