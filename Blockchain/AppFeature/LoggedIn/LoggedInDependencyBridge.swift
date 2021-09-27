// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureDashboardUI
import FeatureSettingsUI
import PlatformUIKit

// These protocols are added here for simplicity,
// these are adopted both by `LoggedInHostingController` and `AppCoordinator`
// The methods and properties provided by these protocol where used by accessing the `.shared` property of AppCoordinator

/// Provider the `TabControllerManager`
protocol TabControllerManagerProvider: AnyObject {
    var tabControllerManager: TabControllerManager? { get }
}

/// Provides the ability to start a backup flow
protocol BackupFlowStarterAPI: AnyObject {
    func startBackupFlow()
}

/// Provides the ability to show settings
protocol SettingsStarterAPI: AnyObject {
    func showSettingsView()
}

/// Provides a reload mechanism that `Wallet` triggers
protocol LoggedInReloadAPI: AnyObject {
    func reload()
}

/// This protocol conforms to a set of certain protocols that were used as part of the
/// older `AppCoordinator` class which was passed around using it's `shared` property
/// This attempts to bridge the two worlds of the `LoggedInHostingController` and any
/// class that uses the extended protocols.
protocol LoggedInBridge: DrawerRouting,
    TabSwapping,
    CurrencyRouting,
    CashIdentityVerificationAnnouncementRouting,
    InterestIdentityVerificationAnnouncementRouting,
    AppCoordinating,
    WalletOperationsRouting,
    TabControllerManagerProvider,
    BackupFlowStarterAPI,
    SettingsStarterAPI,
    LoggedInReloadAPI,
    AuthenticationCoordinating {}

protocol LoggedInDependencyBridgeAPI: AnyObject {
    /// Registers the bridge
    func register(bridge: LoggedInBridge)
    /// Unregisters the bridge
    func unregister()

    /// Provides the `TabControllerManager` for instances that might need
    func resolveTabControllerProvider() -> TabControllerManagerProvider

    /// Provides `BackupFlowStarterAPI` methods
    func resolveBackupFlowStarter() -> BackupFlowStarterAPI

    /// Provides `SettingsStarterAPI` methods
    func resolveSettingsStarter() -> SettingsStarterAPI

    /// Provides `LoggedInReloadAPI` methods
    func resolveLoggedInReload() -> LoggedInReloadAPI

    /// Provides `DrawerRouting` methods
    func resolveDrawerRouting() -> DrawerRouting
    /// Provides `TabSwapping` methods
    func resolveTabSwapping() -> TabSwapping
    /// Provides `CurrencyRouting` methods
    func resolveCurrencyRouting() -> CurrencyRouting
    /// Provides `CashIdentityVerificationAnnouncementRouting` methods
    func resolveCashIdentityVerificationAnnouncementRouting() -> CashIdentityVerificationAnnouncementRouting
    /// Provides `InterestIdentityVerificationAnnouncementRouting` methods
    func resolveInterestIdentityVerificationAnnouncementRouting() -> InterestIdentityVerificationAnnouncementRouting
    /// Provides `AppCoordinating` methods
    func resolveAppCoordinating() -> AppCoordinating
    /// Provides `CurrencyRouting & TabSwapping` methods
    func resolveCurrencyRoutingAndTabSwapping() -> CurrencyRouting & TabSwapping
    /// Provides `WalletOperationsRouting` methods
    func resolveWalletOperationsRouting() -> WalletOperationsRouting
    /// Provides `AuthenticationCoordinating` methods
    func resolveAuthenticationCoordinating() -> AuthenticationCoordinating
}

final class LoggedInDependencyBridge: LoggedInDependencyBridgeAPI {

    private weak var hostingControllerBridge: LoggedInBridge?

    init() {}

    func register(bridge: LoggedInBridge) {
        hostingControllerBridge = bridge
    }

    func unregister() {
        hostingControllerBridge = nil
    }

    func resolveTabControllerProvider() -> TabControllerManagerProvider {
        resolve() as TabControllerManagerProvider
    }

    func resolveBackupFlowStarter() -> BackupFlowStarterAPI {
        resolve() as BackupFlowStarterAPI
    }

    func resolveSettingsStarter() -> SettingsStarterAPI {
        resolve() as SettingsStarterAPI
    }

    func resolveLoggedInReload() -> LoggedInReloadAPI {
        resolve() as LoggedInReloadAPI
    }

    func resolveDrawerRouting() -> DrawerRouting {
        resolve() as DrawerRouting
    }

    func resolveTabSwapping() -> TabSwapping {
        resolve() as TabSwapping
    }

    func resolveCurrencyRouting() -> CurrencyRouting {
        resolve() as CurrencyRouting
    }

    func resolveCashIdentityVerificationAnnouncementRouting() -> CashIdentityVerificationAnnouncementRouting {
        resolve() as CashIdentityVerificationAnnouncementRouting
    }

    func resolveInterestIdentityVerificationAnnouncementRouting() -> InterestIdentityVerificationAnnouncementRouting {
        resolve() as InterestIdentityVerificationAnnouncementRouting
    }

    func resolveAppCoordinating() -> AppCoordinating {
        resolve() as AppCoordinating
    }

    func resolveCurrencyRoutingAndTabSwapping() -> CurrencyRouting & TabSwapping {
        resolve() as CurrencyRouting & TabSwapping
    }

    func resolveWalletOperationsRouting() -> WalletOperationsRouting {
        resolve() as WalletOperationsRouting
    }

    func resolveAuthenticationCoordinating() -> AuthenticationCoordinating {
        resolve() as AuthenticationCoordinating
    }

    /// Resolves the underlying bridge with a type
    /// - precondition: The bridge should conform to the type
    /// - Returns: The underlying bridge as a specific protocol type
    private func resolve<T>() -> T {
        precondition(hostingControllerBridge != nil, "No bridge detected, please first use register(bridge:) method")
        precondition(hostingControllerBridge is T, "Bridge does not conform to \(T.self) protocol")
        return hostingControllerBridge as! T
    }
}
