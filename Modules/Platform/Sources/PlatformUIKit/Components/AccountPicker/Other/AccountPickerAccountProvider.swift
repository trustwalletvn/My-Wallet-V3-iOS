// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol AccountPickerAccountProviding: AnyObject {
    var accounts: Observable<[BlockchainAccount]> { get }
}

public final class AccountPickerAccountProvider: AccountPickerAccountProviding {

    // MARK: - Types

    private enum Error: LocalizedError {
        case loadingFailed(account: BlockchainAccount, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let account, let action, let error):
                let type = String(reflecting: account)
                let asset = account.currencyType.code
                let label = account.label
                return "Failed to load: '\(type)' asset '\(asset)' label '\(label)' action '\(action)'  error '\(error)'."
            }
        }
    }

    // MARK: - Private Properties

    private let action: AssetAction
    private let coincore: CoincoreAPI
    private let singleAccountsOnly: Bool
    private let failSequence: Bool
    private let errorRecorder: ErrorRecording

    // MARK: - Properties

    public var accounts: Observable<[BlockchainAccount]> {
        coincore.allAccounts
            .asObservable()
            .asSingle()
            .map { [singleAccountsOnly] allAccountsGroup -> [BlockchainAccount] in
                if singleAccountsOnly {
                    return allAccountsGroup.accounts
                }
                return [allAccountsGroup] + allAccountsGroup.accounts
            }
            .flatMapFilter(
                action: action,
                failSequence: failSequence,
                onError: { [action, errorRecorder] account, error in
                    let error: Error = .loadingFailed(
                        account: account,
                        action: action,
                        error: error.localizedDescription
                    )
                    errorRecorder.error(error)
                }
            )
            .asObservable()
    }

    // MARK: - Init

    /// Default initializer.
    /// - Parameters:
    ///   - singleAccountsOnly: If the return should be filtered to included only `SingleAccount`s. (opposed to `AccountGroup`s)
    ///   - coincore: A `Coincore` instance.
    ///   - errorRecorder: An `ErrorRecording` instance.
    ///   - action: The desired action. This account provider will only return accounts/account groups that can execute this action.
    ///   - failSequence: A flag indicating if, in the event of a wallet erring out, the whole `accounts: Single<[BlockchainAccount]>` sequence should err or if the offending element should be filtered out. Check `flatMapFilter`.
    public init(
        singleAccountsOnly: Bool,
        coincore: CoincoreAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        action: AssetAction,
        failSequence: Bool
    ) {
        self.action = action
        self.coincore = coincore
        self.singleAccountsOnly = singleAccountsOnly
        self.failSequence = failSequence
        self.errorRecorder = errorRecorder
    }
}
