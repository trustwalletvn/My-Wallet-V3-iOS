// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import FeatureAuthenticationDomain
@testable import PlatformKit
import RxSwift
import ToolKit

final class MockWalletRepository: WalletRepositoryAPI {

    var expectedSessionToken: String?
    var expectedAuthenticatorType: WalletAuthenticatorType = .standard
    var expectedGuid: String?
    var expectedPayload: String?
    var expectedSharedKey: String?
    var expectedPassword: String?
    var expectedSyncPubKeys = false
    var expectedOfflineTokenResponse: Result<NabuOfflineTokenResponse, MissingCredentialsError>!

    var sessionToken: Single<String?> { .just(expectedSessionToken) }
    var payload: Single<String?> { .just(expectedPayload) }
    var sharedKey: Single<String?> { .just(expectedSharedKey) }
    var password: Single<String?> { .just(expectedPassword) }
    var guid: Single<String?> {
        .just(expectedGuid)
    }

    var authenticatorType: Single<WalletAuthenticatorType> { .just(expectedAuthenticatorType) }
    var offlineTokenResponse: Single<NabuOfflineTokenResponse> {
        expectedOfflineTokenResponse.single
    }

    func set(offlineTokenResponse: NabuOfflineTokenResponse) -> Completable {
        perform { [weak self] in
            self?.expectedOfflineTokenResponse = .success(offlineTokenResponse)
        }
    }

    func set(sessionToken: String) -> Completable {
        perform { [weak self] in
            self?.expectedSessionToken = sessionToken
        }
    }

    func set(sharedKey: String) -> Completable {
        perform { [weak self] in
            self?.expectedSharedKey = sharedKey
        }
    }

    func set(password: String) -> Completable {
        perform { [weak self] in
            self?.expectedPassword = password
        }
    }

    func set(guid: String) -> Completable {
        perform { [weak self] in
            self?.expectedGuid = guid
        }
    }

    func set(syncPubKeys: Bool) -> Completable {
        perform { [weak self] in
            self?.expectedSyncPubKeys = syncPubKeys
        }
    }

    func set(language: String) -> Completable {
        .empty()
    }

    func set(authenticatorType: WalletAuthenticatorType) -> Completable {
        perform { [weak self] in
            self?.expectedAuthenticatorType = authenticatorType
        }
    }

    func set(payload: String) -> Completable {
        perform { [weak self] in
            self?.expectedPayload = payload
        }
    }

    func cleanSessionToken() -> Completable {
        perform { [weak self] in
            self?.expectedSessionToken = nil
        }
    }

    func sync() -> Completable {
        perform {}
    }

    private func perform(_ operation: @escaping () -> Void) -> Completable {
        Completable
            .create { observer -> Disposable in
                operation()
                observer(.completed)
                return Disposables.create()
            }
    }

    private func perform<E: Error>(_ operation: @escaping () -> Void) -> AnyPublisher<Void, E> {
        AnyPublisher
            .create { observer -> AnyCancellable in
                operation()
                observer.send(())
                observer.send(completion: .finished)
                return AnyCancellable {}
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - MockWalletRepositoryCombineAPI

extension MockWalletRepository {

    var authenticatorTypePublisher: AnyPublisher<WalletAuthenticatorType, Never> {
        .just(expectedAuthenticatorType)
    }

    func setPublisher(authenticatorType: WalletAuthenticatorType) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedAuthenticatorType = authenticatorType
        }
    }

    func setPublisher(language: String) -> AnyPublisher<Void, Never> {
        .just(())
    }

    var hasPasswordPublisher: AnyPublisher<Bool, Never> {
        hasPassword.asPublisher().ignoreFailure()
    }

    var passwordPublisher: AnyPublisher<String?, Never> {
        .just(expectedPassword)
    }

    func setPublisher(password: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedPassword = password
        }
    }

    func syncPublisher() -> AnyPublisher<Void, PasswordRepositoryError> {
        perform {}
    }

    func setPublisher(payload: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedPayload = payload
        }
    }

    var sessionTokenPublisher: AnyPublisher<String?, Never> {
        .just(expectedSessionToken)
    }

    func setPublisher(sessionToken: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSessionToken = sessionToken
        }
    }

    func cleanSessionTokenPublisher() -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSessionToken = nil
        }
    }

    func setPublisher(syncPubKeys: Bool) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSyncPubKeys = syncPubKeys
        }
    }

    var sharedKeyPublisher: AnyPublisher<String?, Never> {
        .just(expectedSharedKey)
    }

    func setPublisher(sharedKey: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedSharedKey = sharedKey
        }
    }

    var guidPublisher: AnyPublisher<String?, Never> {
        .just(expectedGuid)
    }

    func setPublisher(guid: String) -> AnyPublisher<Void, Never> {
        perform { [weak self] in
            self?.expectedGuid = guid
        }
    }

    var offlineTokenResponsePublisher: AnyPublisher<NabuOfflineTokenResponse, MissingCredentialsError> {
        expectedOfflineTokenResponse.publisher
    }

    func setPublisher(
        offlineTokenResponse: NabuOfflineTokenResponse
    ) -> AnyPublisher<Void, CredentialWritingError> {
        perform { [weak self] in
            self?.expectedOfflineTokenResponse = .success(offlineTokenResponse)
        }
    }
}
