// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAccountPickerDomain
import SwiftUI
import UIComponentsKit

struct AccountPickerRowView: View {

    let store: Store<AccountPickerRow, AccountPickerRowAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Rectangle()
                    .foregroundColor(.viewPrimaryBackground)
                    .contentShape(Rectangle())
                switch viewStore.kind {
                case .accountGroup(let model):
                    AccountGroupRow(model: model)
                case .button(let model):
                    ButtonRow(model: model)
                case .linkedBankAccount(let model):
                    LinkedBankAccountRow(model: model)
                case .singleAccount(let model):
                    SingleAccountRow(model: model)
                }
            }.onTapGesture {
                viewStore.send(.accountPickerRowDidTap(title: viewStore.id.description))
            }
        }
    }
}

private struct AccountGroupRow: View {

    let model: AccountPickerRow.AccountGroupModel

    var body: some View {
        HStack(spacing: 16) {
            if let image = model.badgeImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32.0, height: 32.0)
            }
            VStack {
                HStack {
                    Text(model.title)
                        .textStyle(.heading)
                    Spacer()
                    Text(model.fiatBalance)
                        .textStyle(.heading)
                }
                HStack {
                    Text(model.description)
                        .textStyle(.subheading)
                    Spacer()
                    Text(model.currencyCode)
                        .textStyle(.subheading)
                }
            }
        }
        .padding([.top, .bottom], 10)
    }
}

private struct ButtonRow: View {

    let model: AccountPickerRow.ButtonModel

    var body: some View {
        VStack {
            Button(model.text) {
                print("Button tapped!")
            }
            .padding()
            .frame(height: 48)
            .clipShape(Capsule())
        }
        .padding([.top, .bottom], 10)
    }
}

private struct LinkedBankAccountRow: View {

    let model: AccountPickerRow.LinkedBankAccountModel

    var body: some View {
        HStack(spacing: 16) {
            if let badgeImage = model.badgeImage {
                badgeImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32.0, height: 32.0)
            }
            VStack(spacing: 4) {
                Text(model.title)
                    .textStyle(.heading)
                Text(model.description)
                    .textStyle(.subheading)
                if let multiBadgeView = model.multiBadgeView {
                    multiBadgeView
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32.0, height: 32.0)
                }
            }
        }
        .padding([.top, .bottom], 10)
    }
}

private struct SingleAccountRow: View {

    let model: AccountPickerRow.SingleAccountModel

    var body: some View {
        HStack(spacing: 16) {
            if let image = model.thumbSideImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32.0, height: 32.0)
            }
            VStack {
                HStack {
                    Text(model.title)
                        .textStyle(.heading)
                    Spacer()
                    Text(model.fiatBalance)
                        .textStyle(.heading)
                }
                HStack {
                    Text(model.description)
                        .textStyle(.subheading)
                    Spacer()
                    Text(model.cryptoBalance)
                        .textStyle(.subheading)
                }
            }
        }
        .padding([.top, .bottom], 10)
    }
}

struct AccountPickerRowView_Previews: PreviewProvider {

    static let accountGroupRow = AccountPickerRow(
        kind: .accountGroup(
            AccountPickerRow.AccountGroupModel(
                title: "All Wallets",
                description: "Total Balance",
                fiatBalance: "$2,302.39",
                currencyCode: "USD"
            )
        )
    )

    static let buttonRow = AccountPickerRow(
        kind: .button(AccountPickerRow.ButtonModel(text: "See Balance"))
    )

    static let linkedBankAccountRow = AccountPickerRow(
        kind: .linkedBankAccount(
            AccountPickerRow.LinkedBankAccountModel(
                title: "BTC",
                description: "5243424"
            )
        )
    )

    static let singleAccountRow = AccountPickerRow(
        kind: .singleAccount(
            AccountPickerRow.SingleAccountModel(
                title: "BTC Trading Wallet",
                description: "Bitcoin",
                pending: "0.0",
                fiatBalance: "$2,302.39",
                cryptoBalance: "0.21204887 BTC"
            )
        )
    )

    static var previews: some View {
        Group {
            AccountPickerRowView(
                store: Store(
                    initialState: accountGroupRow,
                    reducer: accountPickerRowReducer,
                    environment: AccountPickerRowEnvironment()
                )
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("AccountGroupRow")

            AccountPickerRowView(
                store: Store(
                    initialState: buttonRow,
                    reducer: accountPickerRowReducer,
                    environment: AccountPickerRowEnvironment()
                )
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("ButtonRow")

            AccountPickerRowView(
                store: Store(
                    initialState: linkedBankAccountRow,
                    reducer: accountPickerRowReducer,
                    environment: AccountPickerRowEnvironment()
                )
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("LinkedBankAccountRow")

            AccountPickerRowView(
                store: Store(
                    initialState: singleAccountRow,
                    reducer: accountPickerRowReducer,
                    environment: AccountPickerRowEnvironment()
                )
            )
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .previewDisplayName("SingleAccountRow")
        }
    }
}
