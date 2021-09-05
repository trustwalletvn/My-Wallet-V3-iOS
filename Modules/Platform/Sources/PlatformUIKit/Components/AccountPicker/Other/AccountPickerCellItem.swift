// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxDataSources
import ToolKit

struct AccountPickerCellItem: IdentifiableType {

    // MARK: - Properties

    enum Presenter {
        case button(ButtonViewModel)
        case linkedBankAccount(LinkedBankAccountCellPresenter)
        case accountGroup(AccountGroupBalanceCellPresenter)
        case singleAccount(AccountCurrentBalanceCellPresenter)
    }

    enum Interactor {
        case button(ButtonViewModel)
        case linkedBankAccount(LinkedBankAccount)
        case accountGroup(AccountGroup, AccountGroupBalanceCellInteractor)
        case singleAccount(SingleAccount, AssetBalanceViewInteracting)
    }

    var identity: AnyHashable {
        if let identifier = account?.identifier {
            return identifier
        }
        if case .button = presenter {
            return "button"
        }
        unimplemented()
    }

    let account: BlockchainAccount?
    let presenter: Presenter

    init(interactor: Interactor, assetAction: AssetAction) {
        switch interactor {
        case .button(let viewModel):
            account = nil
            presenter = .button(viewModel)
        case .linkedBankAccount(let account):
            self.account = account
            presenter = .linkedBankAccount(
                .init(account: account, action: assetAction)
            )
        case .singleAccount(let account, let interactor):
            self.account = account
            presenter = .singleAccount(
                AccountCurrentBalanceCellPresenter(
                    account: account,
                    assetAction: assetAction,
                    interactor: interactor
                )
            )
        case .accountGroup(let account, let interactor):
            self.account = account
            presenter = .accountGroup(
                AccountGroupBalanceCellPresenter(
                    account: account,
                    interactor: interactor
                )
            )
        }
    }
}
