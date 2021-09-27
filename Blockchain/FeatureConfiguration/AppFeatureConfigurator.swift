// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FirebaseRemoteConfig
import PlatformKit
import RxSwift
import ToolKit

final class AppFeatureConfigurator {

    private let remoteConfig: RemoteConfig

    init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()) {
        self.remoteConfig = remoteConfig
    }

    func initialize() {
        fetchRemoteConfig()
    }

    private func fetchRemoteConfig() {
        var expiration = TimeInterval(1 * 60 * 60) // 1 hour
        #if DEBUG
        expiration = TimeInterval(60) // 1 min
        #endif
        remoteConfig.fetch(withExpirationDuration: expiration) { [weak self] status, error in
            guard status == .success, error == nil else {
                print("config fetch error")
                return
            }
            self?.remoteConfig.activate(completion: nil)
        }
    }
}

extension AppFeatureConfigurator: FeatureConfiguratorAPI {
    func configuration<Feature: Decodable>(for feature: AppFeature) -> Result<Feature, FeatureConfigurationError> {
        guard let remoteEnabledKey = feature.remoteEnabledKey else {
            return .failure(.missingKeyRawValue)
        }
        let data = remoteConfig.configValue(forKey: remoteEnabledKey).dataValue
        do {
            return .success(try data.decode(to: Feature.self))
        } catch {
            return .failure(.decodingError)
        }
    }

    /// Returns an `AppFeatureConfiguration` object for the provided feature.
    ///
    /// - Parameter feature: the feature
    /// - Returns: the configuration for the feature requested
    func configuration(for feature: AppFeature) -> AppFeatureConfiguration {

        // If there is no remote key defined for the feature (i.e. if it is not controlled via Firebase),
        // it is enabled by default
        guard let remoteEnabledKey = feature.remoteEnabledKey else {
            return AppFeatureConfiguration(isEnabled: true)
        }

        let isEnabled = remoteConfig.configValue(forKey: remoteEnabledKey).boolValue
        return AppFeatureConfiguration(isEnabled: isEnabled)
    }
}

// MARK: - FeatureDecoding

extension AppFeatureConfigurator: FeatureFetching {

    /// Returns an expected decodable construct for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the decodable object wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value is missing
    /// or a Decoding error if decoding fails.
    func fetch<Feature: Decodable>(for key: AppFeature) -> Single<Feature> {
        fetchConfigValue(for: key)
            .map(\.dataValue)
            .map { data -> Feature in
                try data.decode(to: Feature.self)
            }
    }

    /// Returns an expected string for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the string value wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value is missing
    /// or `ConfigurationError.missingValue` if the value itself is missing.
    func fetchString(for key: AppFeature) -> Single<String> {
        fetchConfigValue(for: key)
            .map(\.stringValue)
            .map { stringValue -> String in
                guard let stringValue = stringValue else {
                    throw FeatureConfigurationError.missingValue
                }
                return stringValue
            }
    }

    /// Returns an expected integer for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the integer value wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value is missing.
    func fetchInteger(for key: AppFeature) -> Single<Int> {
        fetchConfigValue(for: key)
            .map(\.numberValue)
            .map(\.intValue)
    }

    /// Returns an expected boolean for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: The `Bool` value wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value is missing.
    func fetchBool(for key: AppFeature) -> Single<Bool> {
        fetchConfigValue(for: key)
            .map(\.boolValue)
    }

    /// Returns the `RemoteConfigValue` for the given `AppFeature`
    ///
    /// - Parameter feature: the feature key
    /// - Returns: Stream emitting a single `RemoteConfigValue`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value is missing.
    private func fetchConfigValue(for key: AppFeature) -> Single<RemoteConfigValue> {
        guard let keyRawValue = key.remoteEnabledKey else {
            return .error(FeatureConfigurationError.missingKeyRawValue)
        }
        return .just(remoteConfig.configValue(forKey: keyRawValue))
    }
}

// MARK: - FeatureVariantFetching

extension AppFeatureConfigurator: FeatureVariantFetching {
    /// Returns an expected variant for the provided feature key
    ///
    /// - Parameter feature: the feature key
    /// - Returns: the `FeatureTestingVariant` value wrapped in a `RxSwift.Single`
    /// - Throws: An `ConfigurationError.missingKeyRawValue` in case the key raw value is missing
    /// or `ConfigurationError.missingValue` if the value itself is missing.
    func fetchTestingVariant(for key: AppFeature) -> Single<FeatureTestingVariant> {
        fetchString(for: key)
            .map { FeatureTestingVariant(rawValue: $0) ?? .variantA }
    }

    func fetchTestingVariant(for key: AppFeature, onErrorReturn defaultVariant: FeatureTestingVariant) -> Single<FeatureTestingVariant> {
        fetchString(for: key)
            .map { FeatureTestingVariant(rawValue: $0) ?? defaultVariant }
            .catchErrorJustReturn(defaultVariant)
    }
}
