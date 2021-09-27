// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct VerifyDeviceView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.EmailLogin

    private enum Layout {
        static let bottomPadding: CGFloat = 34
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24

        static let imageSideLength: CGFloat = 72
        static let imageBottomPadding: CGFloat = 16
        static let descriptionFontSize: CGFloat = 16
        static let descriptionLineSpacing: CGFloat = 4
        static let buttonSpacing: CGFloat = 10
    }

    private let store: Store<VerifyDeviceState, VerifyDeviceAction>
    private var showOpenMailAppButton: Bool
    @ObservedObject private var viewStore: ViewStore<VerifyDeviceState, VerifyDeviceAction>

    init(store: Store<VerifyDeviceState, VerifyDeviceAction>) {
        self.store = store
        viewStore = ViewStore(store)

        if let mailAppURL = URL(string: "message://"),
           UIApplication.shared.canOpenURL(mailAppURL)
        {
            showOpenMailAppButton = true
        } else {
            showOpenMailAppButton = false
        }
    }

    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image.CircleIcon.verifyDevice
                    .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                    .padding(.bottom, Layout.imageBottomPadding)
                    .accessibility(identifier: AccessibilityIdentifiers.VerifyDeviceScreen.verifyDeviceImage)

                Text(LocalizedString.VerifyDevice.title)
                    .textStyle(.title)
                    .accessibility(identifier: AccessibilityIdentifiers.VerifyDeviceScreen.verifyDeviceTitleText)

                Text(LocalizedString.VerifyDevice.description)
                    .font(Font(weight: .medium, size: Layout.descriptionFontSize))
                    .foregroundColor(.textSubheading)
                    .lineSpacing(Layout.descriptionLineSpacing)
                    .accessibility(identifier: AccessibilityIdentifiers.VerifyDeviceScreen.verifyDeviceDescriptionText)
                Spacer()
            }
            .multilineTextAlignment(.center)

            buttonSection

            NavigationLink(
                destination: IfLetStore(
                    store.scope(
                        state: \.credentialsState,
                        action: VerifyDeviceAction.credentials
                    ),
                    then: { store in
                        CredentialsView(context: viewStore.credentialsContext, store: store)
                    }
                ),
                isActive: viewStore.binding(
                    get: \.isCredentialsScreenVisible,
                    send: VerifyDeviceAction.setCredentialsScreenVisible(_:)
                ),
                label: EmptyView.init
            )
        }
        .padding(
            EdgeInsets(
                top: 0,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .hideBackButtonTitle()
        .alert(self.store.scope(state: \.verifyDeviceFailureAlert), dismiss: .verifyDeviceFailureAlert(.dismiss))
    }

    private var buttonSection: some View {
        VStack(spacing: Layout.buttonSpacing) {
            SecondaryButton(
                title: LocalizedString.Button.sendAgain,
                action: {
                    viewStore.send(.sendDeviceVerificationEmail)
                },
                loading: viewStore.binding(get: \.sendEmailButtonIsLoading, send: .none)
            )
            .disabled(viewStore.sendEmailButtonIsLoading)
            .accessibility(identifier: AccessibilityIdentifiers.VerifyDeviceScreen.sendAgainButton)
            if showOpenMailAppButton {
                PrimaryButton(title: LocalizedString.Button.openEmail) {
                    viewStore.send(.openMailApp)
                }
                .accessibility(identifier: AccessibilityIdentifiers.VerifyDeviceScreen.openMailAppButton)
            }
        }
    }
}

#if DEBUG
struct VerifyDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyDeviceView(
            store:
            Store(
                initialState: .init(emailAddress: ""),
                reducer: verifyDeviceReducer,
                environment: .init(
                    mainQueue: .main,
                    deviceVerificationService: NoOpDeviceVerificationService(),
                    errorRecorder: NoOpErrorRecorder(),
                    analyticsRecorder: NoOpAnalyticsRecorder()
                )
            )
        )
    }
}
#endif
