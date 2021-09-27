// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

struct UnlockTradingViewModel: Equatable {

    struct Benefit: Equatable {
        let title: String
        let message: String
        let iconName: String
    }

    struct Action: Equatable {
        enum ActionStyle: Equatable {
            case primary
            case secondary
        }

        let title: String
        let style: ActionStyle
        let action: (ViewStore<UnlockTradingState, UnlockTradingAction>) -> Void

        static func == (lhs: UnlockTradingViewModel.Action, rhs: UnlockTradingViewModel.Action) -> Bool {
            lhs.title == rhs.title && lhs.style == rhs.style
        }
    }

    let title: String
    let message: String
    let viewIconName: String
    let topBackgroundImageName: String?
    let benefits: [Benefit]
    let actions: [Action]
}

extension UnlockTradingViewModel {

    static let unlockGoldTier = UnlockTradingViewModel(
        title: NSLocalizedString("Unlock Gold Level Trading", comment: ""),
        message: NSLocalizedString(
            "Verify your identity, earn rewards and trade up to $10,000 a day.",
            comment: ""
        ),
        viewIconName: "icon-bank",
        topBackgroundImageName: "top-screen-pattern",
        benefits: [
            Benefit(
                title: NSLocalizedString("Cash Accounts", comment: ""),
                message: NSLocalizedString(
                    "Store USD, GBP or EUR in your wallet. Use the balance to buy crypto. Sell crypto for cash at anytime.",
                    comment: ""
                ),
                iconName: "icon-cash"
            ),
            Benefit(
                title: NSLocalizedString("Link a Bank", comment: ""),
                message: NSLocalizedString(
                    "Connect your Wallet to any bank or credit union. Deposit and Withdraw Cash at anytyime.",
                    comment: ""
                ),
                iconName: "icon-bank"
            ),
            Benefit(
                title: NSLocalizedString("Earn Rewards", comment: ""),
                message: NSLocalizedString(
                    "Put your crypto to work. Earn up to 10% monthly by simply doing nothing. Instanly deposit and start earning.",
                    comment: ""
                ),
                iconName: "icon-interest"
            )
        ],
        actions: [
            Action(
                title: NSLocalizedString("Apply & Unlock Now", comment: ""),
                style: .primary,
                action: { viewStore in
                    viewStore.send(.unlockButtonTapped)
                }
            )
        ]
    )
}
