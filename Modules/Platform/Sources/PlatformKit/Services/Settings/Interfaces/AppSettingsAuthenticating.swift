// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol AppSettingsAuthenticating: AnyObject {
    var pin: String? { get set }
    var pinKey: String? { get set }
    var biometryEnabled: Bool { get set }
    var passwordPartHash: String? { get set }
    var encryptedPinPassword: String? { get set }
    var isPairedWithWallet: Bool { get }
    var isPinSet: Bool { get }
    func clearPin()
}

// TICKET: IOS-2738
// TODO: Refactor BlockchainSettings.App/Onboarding Rx code to be thread-safe
extension AppSettingsAuthenticating {

    public var isPinSet: Bool {
        pinKey != nil && encryptedPinPassword != nil
    }

    public var pin: Single<String?> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.pin)
        }
    }

    public var pinKey: Single<String?> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.pinKey)
        }
    }

    public var biometryEnabled: Single<Bool> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.biometryEnabled)
        }
    }

    public var passwordPartHash: Single<String?> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.passwordPartHash)
        }
    }

    public var encryptedPinPassword: Single<String?> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.encryptedPinPassword)
        }
    }

    public var isPairedWithWallet: Single<Bool> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.isPairedWithWallet)
        }
    }
}
