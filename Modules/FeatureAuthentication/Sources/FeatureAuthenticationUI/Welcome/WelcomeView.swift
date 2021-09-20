// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

/// Entry point to Create Wallet/Login/Restore Wallet
public struct WelcomeView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.Welcome

    private enum Layout {
        static let topPadding: CGFloat = 140
        static let bottomPadding: CGFloat = 58
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24

        static let imageSideLength: CGFloat = 64
        static let imageBottomPadding: CGFloat = 40
        static let titleFontSize: CGFloat = 24
        static let titleBottomPadding: CGFloat = 16
        static let messageFontSize: CGFloat = 16
        static let messageLineSpacing: CGFloat = 4
        static let buttonSpacing: CGFloat = 10
        static let buttonFontSize: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 20
        static let supplmentaryTextFontSize: CGFloat = 12
    }

    private let store: Store<WelcomeState, WelcomeAction>
    @ObservedObject private var viewStore: ViewStore<WelcomeState, WelcomeAction>

    public init(store: Store<WelcomeState, WelcomeAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    public var body: some View {
        VStack {
            welcomeMessageSection
            Spacer()
            buttonSection
                .padding(.bottom, Layout.buttonBottomPadding)
            supplementarySection
        }
        .padding(
            EdgeInsets(
                top: Layout.topPadding,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .sheet(
            isPresented: .constant(
                viewStore.screenFlow == .emailLoginScreen
                    || viewStore.screenFlow == .manualLoginScreen
                    || viewStore.modals == .secondPasswordNoticeScreen
            ),
            onDismiss: {
                if viewStore.modals == .secondPasswordNoticeScreen {
                    viewStore.send(.modalDismissed(.secondPasswordNoticeScreen))
                }
            },
            content: {
                if viewStore.screenFlow == .emailLoginScreen {
                    IfLetStore(
                        store.scope(
                            state: \.emailLoginState,
                            action: WelcomeAction.emailLogin
                        ),
                        then: EmailLoginView.init(store:)
                    )
                } else if viewStore.screenFlow == .manualLoginScreen {
                    IfLetStore(
                        store.scope(
                            state: \.manualCredentialsState,
                            action: WelcomeAction.manualPairing
                        ),
                        then: { store in
                            NavigationView {
                                CredentialsView(
                                    context: .manualPairing,
                                    store: store
                                )
                                .trailingNavigationButton(.close) {
                                    viewStore.send(.manualPairing(.closeButtonTapped))
                                }
                                .whiteNavigationBarStyle()
                                .navigationTitle(
                                    LocalizedString.Button.manualPairing
                                )
                            }
                        }
                    )
                } else if viewStore.modals == .secondPasswordNoticeScreen {
                    IfLetStore(
                        store.scope(
                            state: \.secondPasswordNoticeState,
                            action: WelcomeAction.secondPasswordNotice
                        ),
                        then: { store in
                            NavigationView {
                                SecondPasswordNoticeView(store: store)
                            }
                        }
                    )
                }
            }
        )
    }

    // MARK: - Private

    private var welcomeMessageSection: some View {
        VStack {
            Image.Logo.blockchain
                .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                .padding(.bottom, Layout.imageBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.blockchainImage)
            Text(LocalizedString.title)
                .font(Font(weight: .semibold, size: Layout.titleFontSize))
                .foregroundColor(.textHeading)
                .padding(.bottom, Layout.titleBottomPadding)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.welcomeTitleText)
            welcomeMessageDescription
                .font(Font(weight: .medium, size: Layout.messageFontSize))
                .lineSpacing(Layout.messageLineSpacing)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.welcomeMessageText)
        }
        .multilineTextAlignment(.center)
    }

    private var welcomeMessageDescription: some View {
        Text(LocalizedString.Description.prefix)
            .foregroundColor(.textMuted) +
            Text(LocalizedString.Description.send)
            .foregroundColor(.textHeading) +
            Text(LocalizedString.Description.comma)
            .foregroundColor(.textMuted) +
            Text(LocalizedString.Description.receive)
            .foregroundColor(.textHeading) +
            Text(LocalizedString.Description.comma)
            .foregroundColor(.textMuted) +
            Text(LocalizedString.Description.store + "\n")
            .foregroundColor(.textHeading) +
            Text(LocalizedString.Description.and)
            .foregroundColor(.textMuted) +
            Text(LocalizedString.Description.trade)
            .foregroundColor(.textHeading) +
            Text(LocalizedString.Description.suffix)
            .foregroundColor(.textMuted)
    }

    private var buttonSection: some View {
        VStack(spacing: Layout.buttonSpacing) {
            PrimaryButton(title: LocalizedString.Button.createWallet) {
                viewStore.send(.presentScreenFlow(.createWalletScreen))
            }
            .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.createWalletButton)
            SecondaryButton(title: LocalizedString.Button.login) {
                viewStore.send(.presentScreenFlow(.emailLoginScreen))
            }
            .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.emailLoginButton)
            if viewStore.manualPairingEnabled {
                Divider()
                manualPairingButton()
                    .accessibility(
                        identifier: AccessibilityIdentifiers.WelcomeScreen.manualPairingButton
                    )
            }
        }
        .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.emailLoginButton)
    }

    private var supplementarySection: some View {
        HStack {
            Button(LocalizedString.Button.restoreWallet) {
                viewStore.send(.presentScreenFlow(.recoverWalletScreen))
            }
            .font(Font(weight: .semibold, size: Layout.supplmentaryTextFontSize))
            .foregroundColor(.buttonLinkText)
            .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.restoreWalletButton)
            Spacer()
            Text(viewStore.buildVersion)
                .font(Font(weight: .medium, size: Layout.supplmentaryTextFontSize))
                .foregroundColor(.textMuted)
                .accessibility(identifier: AccessibilityIdentifiers.WelcomeScreen.buildVersionText)
        }
    }

    private func manualPairingButton() -> some View {
        Button(LocalizedString.Button.manualPairing) {
            viewStore.send(.presentScreenFlow(.manualLoginScreen))
        }
        .font(Font(weight: .semibold, size: Layout.buttonFontSize))
        .frame(maxWidth: .infinity, minHeight: LayoutConstants.buttonMinHeight)
        .padding(.horizontal)
        .foregroundColor(Color.textSubheading)
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                .fill(Color.buttonSecondaryBackground)
        )
        .background(
            RoundedRectangle(cornerRadius: LayoutConstants.buttonCornerRadious)
                .stroke(Color.borderPrimary)
        )
    }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            store: Store(
                initialState: .init(),
                reducer: welcomeReducer,
                environment: .init(
                    mainQueue: .main,
                    sessionTokenService: NoOpSessionTokenService(),
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    featureFlags: NoOpInternalFeatureFlagService(),
                    buildVersionProvider: { "Test version" }
                )
            )
        )
    }
}
#endif
