// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import RxCombine
import RxSwift
import ToolKit

public protocol WalletUpgradeServicing {
    /// Indicates if the wallet needs any payload upgrade.
    /// Crashes if the wallet is not initalized.
    var needsWalletUpgrade: Single<Bool> { get }

    /// Indicates if the wallet needs any payload upgrade.
    /// Crashes if the wallet is not initalized.
    var needsWalletUpgradePublisher: AnyPublisher<Bool, Error> { get }

    /// Upgrades the user wallet to the most recent version.
    /// Emits the current version being upgrade.
    /// Completes when the work is done.
    /// Errors when something went wrong.
    func upgradeWallet() -> Observable<String>
}

final class WalletUpgradeService: WalletUpgradeServicing {

    // MARK: Types

    enum WalletError: Error {
        case walletNotInitialized
    }

    enum PayloadVersion: String {
        case v3
        case v4
    }

    // MARK: Private Properties

    private let errorRecorder: ErrorRecording
    private let walletUpgradeJSService: WalletUpgradeJSServicing
    private let wallet: WalletUpgradingAPI

    // MARK: Init

    init(
        errorRecorder: ErrorRecording = resolve(),
        wallet: WalletUpgradingAPI = resolve(),
        walletUpgradeJSService: WalletUpgradeJSServicing = resolve()
    ) {
        self.errorRecorder = errorRecorder
        self.wallet = wallet
        self.walletUpgradeJSService = walletUpgradeJSService
    }

    // MARK: WalletUpgradeServicing

    var needsWalletUpgrade: Single<Bool> {
        guard wallet.isInitialized else {
            errorRecorder.error(WalletError.walletNotInitialized)
            return .just(false)
        }
        return necessaryUpgrades.map(\.isEmpty).map(!)
    }

    var needsWalletUpgradePublisher: AnyPublisher<Bool, Error> {
        guard wallet.isInitialized else {
            errorRecorder.error(WalletError.walletNotInitialized)
            return .just(false)
        }
        return necessaryUpgrades
            .map(\.isEmpty)
            .map(!)
            .asPublisher()
    }

    func upgradeWallet() -> Observable<String> {
        necessaryWorkflows()
            .asObservable()
            .map { workflows in
                Observable.concat(workflows)
            }
            .flatMap { $0 }
    }

    // MARK: Private Methods

    private func workflow(for version: PayloadVersion) -> Single<String> {
        switch version {
        case .v3:
            return walletUpgradeJSService.upgradeToV3()
        case .v4:
            return walletUpgradeJSService.upgradeToV4()
        }
    }

    /// - Returns: Ordered array of necessary payload upgrades.
    private var necessaryUpgrades: Single<[PayloadVersion]> {
        var upgrades: [PayloadVersion] = []
        guard wallet.isInitialized else {
            return .just(upgrades)
        }
        // Check if wallet was already upgrade to V3.
        if !wallet.didUpgradeToV3 {
            upgrades.append(.v3)
        }
        // Check if wallet was already upgrade to V4.
        if !wallet.didUpgradeToV4 {
            // Fetch if is necessary to upgrade to V4 based on Wallet Settings.
            return wallet.requiresV4Upgrade
                .map { requiresV4Upgrade -> [PayloadVersion] in
                    if requiresV4Upgrade {
                        upgrades.append(.v4)
                    }
                    return upgrades
                }
                .catchError { _ -> PrimitiveSequence<SingleTrait, [PayloadVersion]> in
                    .just(upgrades)
                }
        }
        return .just(upgrades)
    }

    private func wait(for workflows: [Observable<String>]) -> Observable<String> {
        Observable.concat(workflows)
    }

    /// Maps the list of necessary upgrades into their workflows.
    /// Because we want the version to be updated to be emitted before the work is started, we `.startWith` it.
    /// We catch any error and throw `WalletUpgradeError.errorUpgrading` instead.
    private func necessaryWorkflows() -> Single<[Observable<String>]> {
        necessaryUpgrades.map(weak: self) { (self, necessaryUpgrades) in
            necessaryUpgrades
                .map { version in
                    self.workflow(for: version)
                        .asObservable()
                        .startWith(version.rawValue)
                        .catchError { _ -> Observable<String> in
                            .error(WalletUpgradeError.errorUpgrading(version: version.rawValue))
                        }
                }
        }
    }
}
