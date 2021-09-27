// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import RxRelay
import RxSwift
import ToolKit

final class SettingsService: SettingsServiceAPI {

    // MARK: - Exposed Properties

    /// Streams the first available settings element
    var valueSingle: Single<WalletSettings> {
        valueObservable
            .take(1)
            .asSingle()
    }

    var valueObservable: Observable<WalletSettings> {
        settingsRelay
            .flatMap(weak: self) { (self, settings) -> Observable<WalletSettings> in
                guard let settings = settings else {
                    return self.fetch(force: false).asObservable()
                }
                return .just(settings)
            }
            .distinctUntilChanged()
    }

    // MARK: - Private Properties

    private let client: SettingsClientAPI
    private let credentialsRepository: CredentialsRepositoryAPI

    private let settingsRelay = BehaviorRelay<WalletSettings?>(value: nil)
    private let disposeBag = DisposeBag()
    private let scheduler = SerialDispatchQueueScheduler(qos: .default)
    private let semaphore = DispatchSemaphore(value: 1)

    // MARK: - Setup

    init(
        client: SettingsClientAPI = resolve(),
        credentialsRepository: CredentialsRepositoryAPI = resolve()
    ) {
        self.client = client
        self.credentialsRepository = credentialsRepository

        NotificationCenter.when(.login) { [weak self] _ in
            self?.settingsRelay.accept(nil)
        }

        NotificationCenter.when(.logout) { [weak self] _ in
            self?.settingsRelay.accept(nil)
        }
    }

    // MARK: - Public Methods

    func fetch(force: Bool) -> Single<WalletSettings> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            guard case .success = self.semaphore.wait(timeout: .now() + .seconds(30)) else {
                observer(.error(ToolKitError.timedOut))
                return Disposables.create()
            }
            let disposable = self.settingsRelay
                .take(1)
                .asSingle()
                .flatMap(weak: self) { (self, settings: WalletSettings?) -> Single<WalletSettings> in
                    self.fetchSettings(settings: settings, force: force)
                }
                .subscribe { event in
                    switch event {
                    case .success(let settings):
                        observer(.success(settings))
                    case .error(let error):
                        observer(.error(error))
                    }
                }

            return Disposables.create {
                disposable.dispose()
                self.semaphore.signal()
            }
        }
        .subscribeOn(scheduler)
    }

    private func fetchSettings(settings: WalletSettings?, force: Bool) -> Single<WalletSettings> {
        guard force || settings == nil else { return Single.just(settings!) }
        return credentialsRepository.credentials
            .flatMap(weak: self) { (self, credentials) in
                self.client.settings(
                    by: credentials.guid,
                    sharedKey: credentials.sharedKey
                )
                .asSingle()
            }
            .map { WalletSettings(response: $0) }
            .do(onSuccess: { [weak self] settings in
                self?.settingsRelay.accept(settings)
            })
    }
}

extension SettingsService {

    // MARK: - SettingsServiceCombineAPI

    var singleValuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> {
        valueSingle
            .asObservable()
            .publisher
            .mapError { error -> SettingsServiceError in
                switch error {
                case ToolKitError.timedOut:
                    return .timedOut
                default:
                    return .fetchFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }

    var valuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> {
        valueObservable
            .publisher
            .mapError { error -> SettingsServiceError in
                switch error {
                case ToolKitError.timedOut:
                    return .timedOut
                default:
                    return .fetchFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchPublisher(force: Bool) -> AnyPublisher<WalletSettings, SettingsServiceError> {
        fetch(force: force)
            .asObservable()
            .publisher
            .mapError { error -> SettingsServiceError in
                switch error {
                case ToolKitError.timedOut:
                    return .timedOut
                default:
                    return .fetchFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - FiatCurrencySettingsServiceAPI

extension SettingsService: FiatCurrencySettingsServiceAPI {

    var fiatCurrencyObservable: Observable<FiatCurrency> {
        valueObservable
            .map { settings -> FiatCurrency in
                guard let currency = FiatCurrency(rawValue: settings.fiatCurrency) else {
                    throw PlatformKitError.default
                }
                return currency
            }
            .distinctUntilChanged()
    }

    var fiatCurrency: Single<FiatCurrency> {
        valueSingle
            .map { settings -> FiatCurrency in
                guard let currency = settings.currency else {
                    throw PlatformKitError.default
                }
                return currency
            }
    }

    func update(currency: FiatCurrency, context: FlowContext) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    currency: currency.code,
                    context: context,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
                .asObservable()
                .ignoreElements()
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }

    func update(currency: FiatCurrency, context: FlowContext) -> AnyPublisher<Void, CurrencyUpdateError> {
        let fetch = fetchPublisher(force: true)
        return credentialsRepository.credentialsPublisher
            .mapError(CurrencyUpdateError.credentialsError)
            .flatMap { [client] (guid: String, sharedKey: String) in
                client.updatePublisher(
                    currency: currency.code,
                    context: context,
                    guid: guid,
                    sharedKey: sharedKey
                )
            }
            .flatMap { _ in
                fetch
                    .mapToVoid()
                    .mapError(CurrencyUpdateError.fetchError)
            }
            .eraseToAnyPublisher()
    }

    @available(*, deprecated, message: "Do not use this. Instead use `FiatCurrencyServiceAPI`")
    var legacyCurrency: FiatCurrency? {
        settingsRelay.value?.currency
    }
}

// MARK: - SettingsEmailUpdateServiceAPI

extension SettingsService: EmailSettingsServiceAPI {

    var email: Single<String> {
        valueSingle.map(\.email)
    }

    func update(email: String, context: FlowContext?) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    email: email,
                    context: context,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
                .asObservable()
                .ignoreElements()
            }
    }

    func update(email: String) -> AnyPublisher<String, EmailSettingsServiceError> {
        credentialsRepository.credentialsPublisher
            .mapError(EmailSettingsServiceError.credentialsError)
            .flatMap { [client] guid, sharedKey in
                client.update(
                    email: email,
                    context: nil,
                    guid: guid,
                    sharedKey: sharedKey
                )
                .mapError(EmailSettingsServiceError.networkError)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - LastTransactionSettingsUpdateServiceAPI

extension SettingsService: LastTransactionSettingsUpdateServiceAPI {
    func updateLastTransaction() -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.updateLastTransactionTime(
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
                .asObservable()
                .ignoreElements()
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
}

// MARK: - EmailNotificationSettingsServiceAPI

extension SettingsService: EmailNotificationSettingsServiceAPI {
    func emailNotifications(enabled: Bool) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.emailNotifications(
                    enabled: enabled,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
                .asObservable()
                .ignoreElements()
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
}

// MARK: - UpdateMobileSettingsServiceAPI

extension SettingsService: UpdateMobileSettingsServiceAPI {
    func update(mobileNumber: String) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.update(
                    smsNumber: mobileNumber,
                    context: .settings,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
                .asObservable()
                .ignoreElements()
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
}

// MARK: - VerifyMobileSettingsServiceAPI

extension SettingsService: VerifyMobileSettingsServiceAPI {
    func verify(with code: String) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.verifySMS(
                    code: code,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
                .asObservable()
                .ignoreElements()
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
}

// MARK: - SMSTwoFactorSettingsServiceAPI

extension SettingsService: SMSTwoFactorSettingsServiceAPI {
    func smsTwoFactorAuthentication(enabled: Bool) -> Completable {
        credentialsRepository.credentials
            .flatMapCompletable(weak: self) { (self, payload) -> Completable in
                self.client.smsTwoFactorAuthentication(
                    enabled: enabled,
                    guid: payload.guid,
                    sharedKey: payload.sharedKey
                )
                .asObservable()
                .ignoreElements()
            }
            .flatMapSingle(weak: self) { (self) in
                self.fetch(force: true)
            }
            .asCompletable()
    }
}
