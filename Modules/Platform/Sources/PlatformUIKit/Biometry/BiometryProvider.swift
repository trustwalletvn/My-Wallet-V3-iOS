// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import LocalAuthentication
import Localization
import PlatformKit
import RxSwift
import ToolKit

/// This objectp provides biometry authentication support
public final class BiometryProvider: BiometryProviding {

    // MARK: - Properties

    /// Returns the status of biometrics configuration on the app and device
    public var configurationStatus: Biometry.Status {
        switch canAuthenticate {
        case .success(let biometryType):
            // Verify configuration in remote
            guard featureConfigurator.configuration(for: .biometry).isEnabled else {
                return .unconfigurable(Biometry.EvaluationError.notAllowed)
            }

            // Biometrics id is already configured - therefore, return it
            if settings.biometryEnabled {
                return .configured(biometryType)
            } else { // Biometrics has not yet been configured within the app
                return .configurable(biometryType)
            }
        case .failure(let error):
            return .unconfigurable(error)
        }
    }

    /// Returns the configured biometrics, if any
    public var configuredType: Biometry.BiometryType {
        if configurationStatus.isConfigured {
            return configurationStatus.biometricsType
        } else {
            return .none
        }
    }

    /// Returns the supported device biometrics, regardless if currently configured in app
    public var supportedBiometricsType: Biometry.BiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return .init(with: context.biometryType)
    }

    /// Evaluates whether the device owner can authenticate using biometrics.
    public var canAuthenticate: Result<Biometry.BiometryType, Biometry.EvaluationError> {
        let context = LAContext()
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )
        if let error = error {
            let biometryError = Biometry.BiometryError(with: error, type: Biometry.BiometryType(with: context.biometryType))
            return .failure(.system(biometryError))
        } else if !canEvaluate {
            return .failure(.notAllowed)
        } else { // Success
            return .success(.init(with: context.biometryType))
        }
    }

    // MARK: - Services

    private let featureConfigurator: FeatureConfiguring
    private let settings: AppSettingsAuthenticating

    // MARK: - Setup

    public init(
        settings: AppSettingsAuthenticating = resolve(),
        featureConfigurator: FeatureConfiguring
    ) {
        self.settings = settings
        self.featureConfigurator = featureConfigurator
    }

    /// Performs authentication if possible
    public func authenticate(reason: Biometry.Reason) -> Single<Void> {
        switch canAuthenticate {
        case .success:
            return performAuthentication(with: reason)
        case .failure(error: let error):
            return .error(error)
        }
    }

    // MARK: - Accessors

    /// Performs authentication
    private func performAuthentication(with reason: Biometry.Reason) -> Single<Void> {
        Single.create { observer -> Disposable in
            let context = LAContext()
            context.localizedFallbackTitle = LocalizationConstants.Biometry.usePasscode
            context.localizedCancelTitle = LocalizationConstants.Biometry.cancelButton
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason.localized,
                reply: { authenticated, error in
                    if let error = error {
                        let biometryError = Biometry.BiometryError(with: error, type: Biometry.BiometryType(with: context.biometryType))
                        observer(.error(Biometry.EvaluationError.system(biometryError)))
                    } else if !authenticated {
                        observer(.error(Biometry.EvaluationError.notAllowed))
                    } else { // Success
                        observer(.success(()))
                    }
                }
            )
            return Disposables.create()
        }
    }
}
