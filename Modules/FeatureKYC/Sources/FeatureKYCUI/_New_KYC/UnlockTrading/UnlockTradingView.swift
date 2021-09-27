// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI
import UIComponentsKit

struct UnlockTradingView: View {

    let store: Store<UnlockTradingState, UnlockTradingAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack(alignment: .topLeading) {
                BackgroundHeaderView {
                    viewStore.send(.closeButtonTapped)
                }
                ActionableView(
                    content: {
                        UnlockTradingViewHelper(viewModel: viewStore.viewModel)
                        Spacer()
                    },
                    buttons: viewStore.viewModel.actions.map { button in
                        ActionableView.ButtonState(
                            title: button.title,
                            action: {
                                button.action(viewStore)
                            },
                            style: button.style == .primary ? .primary : .secondary
                        )
                    }
                )
            }
        }
    }
}

private struct BackgroundHeaderView: View {

    let trailingButtonAction: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image("top-screen-pattern", bundle: .featureKYCUI)
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .scaledToFit()
                NavigationButton.close
                    .button(action: trailingButtonAction)
                    .padding()
            }
            Spacer()
        }
    }
}

private struct UnlockTradingViewHelper: View {

    private enum UIConstants {
        static let textSpacing: CGFloat = 0
        static let largeIconSize: CGFloat = 32
    }

    let viewModel: UnlockTradingViewModel

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: LayoutConstants.VerticalSpacing.betweenContentGroups
        ) {
            Image("icon-bank", bundle: .featureKYCUI)
                .resizable()
                .frame(
                    width: UIConstants.largeIconSize,
                    height: UIConstants.largeIconSize
                )
                .scaledToFit()
                .padding(.top)
            VStack(alignment: .leading, spacing: UIConstants.textSpacing) {
                Text(viewModel.title)
                    .textStyle(.title)
                Text(viewModel.message)
                    .textStyle(.body)
            }
            Spacer()
                .frame(height: 0) // just to double the spacing
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: LayoutConstants.VerticalSpacing.betweenContentGroupsLarge
                ) {
                    ForEach(viewModel.benefits, id: \.title) { benefit in
                        UnlockTradingBenefitView(benefit: benefit)
                    }
                }
            }
            Spacer()
        }
    }
}

private struct UnlockTradingBenefitView: View {

    private enum UIConstants {
        static let groupsSpacing: CGFloat = 10
        static let textSpacing: CGFloat = 0
        static let iconSize: CGFloat = 24
    }

    let benefit: UnlockTradingViewModel.Benefit

    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.groupsSpacing) {
            Image(benefit.iconName, bundle: .featureKYCUI)
                .resizable()
                .frame(
                    width: UIConstants.iconSize,
                    height: UIConstants.iconSize
                )
                .scaledToFit()
            VStack(alignment: .leading, spacing: UIConstants.textSpacing) {
                Text(benefit.title)
                    .textStyle(.heading)
                Text(benefit.message)
                    .textStyle(.subheading)
            }
        }
    }
}

#if DEBUG
struct UnlockTradingView_Previews: PreviewProvider {

    static var previews: some View {
        UnlockTradingView(
            store: .init(
                initialState: UnlockTradingState(
                    viewModel: .unlockGoldTier
                ),
                reducer: unlockTradingReducer,
                environment: UnlockTradingEnvironment(
                    dismiss: {},
                    unlock: {}
                )
            )
        )
    }
}
#endif
