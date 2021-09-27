// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import Localization
import SwiftUI
import ToolKit
import UIComponentsKit

struct CreateAccountView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.CreateAccount

    private enum Layout {
        static let topPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 34
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let footnoteTopPadding: CGFloat = 1
        static let textFieldSpacing: CGFloat = 20

        static let messageFontSize: CGFloat = 12
        static let lineSpacing: CGFloat = 4
    }

    private let store: Store<CreateAccountState, CreateAccountAction>
    @ObservedObject private var viewStore: ViewStore<CreateAccountState, CreateAccountAction>

    @State private var isEmailFieldFirstResponder: Bool = true
    @State private var isPasswordFieldFirstResponder: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordFieldFirstResponder: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false

    init(store: Store<CreateAccountState, CreateAccountAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading) {

            emailField
                .padding(.bottom, Layout.textFieldSpacing)
                .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.emailGroup)

            passwordField
                .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.passwordGroup)

            PasswordStrengthIndicatorView(
                passwordStrength: viewStore.binding(
                    get: \.passwordStrength,
                    send: .none
                )
            )
            .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.passwordStrengthIndicatorGroup)

            confirmPasswordField
                .padding(.top, Layout.textFieldSpacing)
                .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.confirmPasswordGroup)

            agreementText
                .font(Font(weight: .medium, size: Layout.messageFontSize))
                .lineSpacing(Layout.lineSpacing)
                .padding(.top, Layout.footnoteTopPadding)
                .padding(.bottom, Layout.textFieldSpacing)

            Spacer()

            PrimaryButton(title: LocalizedString.createAccountButton) {
                // TODO: create account
            }
            .disabled(viewStore.password.isEmpty || viewStore.password != viewStore.confirmPassword)
            .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.createAccountButton)
        }
        .navigationBarTitle(LocalizedString.navigationTitle, displayMode: .inline)
        .padding(
            EdgeInsets(
                top: Layout.topPadding,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
    }

    private var agreementText: some View {
        VStack(alignment: .leading, spacing: Layout.lineSpacing) {
            Text(LocalizedString.agreementPrompt + " ")
                .foregroundColor(.textSubheading)
                .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.agreementPromptText)
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(LocalizedString.termsOfServiceLink)
                    .foregroundColor(.buttonLinkText)
                    .onTapGesture {
                        guard let url = URL(string: Constants.HostURL.terms) else { return }
                        viewStore.send(.openExternalLink(url))
                    }
                    .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.termsOfServiceButton)
                Text(" " + LocalizedString.and + " ")
                    .foregroundColor(.textSubheading)
                Text(LocalizedString.privacyPolicyLink)
                    .foregroundColor(.buttonLinkText)
                    .onTapGesture {
                        guard let url = URL(string: Constants.HostURL.privacyPolicy) else { return }
                        viewStore.send(.openExternalLink(url))
                    }
                    .accessibility(identifier: AccessibilityIdentifiers.CreateAccountScreen.privacyPolicyButton)
            }
        }
    }

    private var emailField: some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: \.emailAddress,
                send: { .didChangeEmailAddress($0) }
            ),
            isFirstResponder: $isEmailFieldFirstResponder,
            isError: viewStore.binding(
                get: { !$0.emailAddress.isEmail && !$0.emailAddress.isEmpty },
                send: .none
            ),
            title: LocalizedString.TextFieldTitle.email,
            configuration: {
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.textContentType = .emailAddress
                $0.keyboardType = .emailAddress
                $0.placeholder = LocalizedString.TextFieldPlaceholder.email
                $0.returnKeyType = .next
                $0.enablesReturnKeyAutomatically = true
            },
            errorMessage: LocalizedString.TextFieldError.invalidEmail,
            onPaddingTapped: {
                self.isEmailFieldFirstResponder = true
                self.isPasswordFieldFirstResponder = false
                self.isConfirmPasswordFieldFirstResponder = false
            },
            onReturnTapped: {
                self.isEmailFieldFirstResponder = false
                self.isPasswordFieldFirstResponder = true
                self.isConfirmPasswordFieldFirstResponder = false
            }
        )
    }

    private var passwordField: some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: \.password,
                send: { .didChangePassword($0) }
            ),
            isFirstResponder: $isPasswordFieldFirstResponder,
            isError: .constant(false),
            title: LocalizedString.TextFieldTitle.password,
            configuration: {
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.isSecureTextEntry = !isPasswordVisible
                $0.textContentType = .newPassword
                $0.placeholder = LocalizedString.TextFieldPlaceholder.password
            },
            onPaddingTapped: {
                self.isEmailFieldFirstResponder = false
                self.isPasswordFieldFirstResponder = true
                self.isConfirmPasswordFieldFirstResponder = false
            },
            onReturnTapped: {
                self.isEmailFieldFirstResponder = false
                self.isPasswordFieldFirstResponder = false
                self.isConfirmPasswordFieldFirstResponder = true
            },
            trailingAccessoryView: {
                PasswordEyeSymbolButton(isPasswordVisible: $isPasswordVisible)
            }
        )
    }

    private var passwordInstruction: some View {
        Text(LocalizedString.passwordInstruction)
            .font(Font(weight: .medium, size: 12))
            .foregroundColor(.textSubheading)
    }

    private var confirmPasswordField: some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: \.confirmPassword,
                send: { .didChangeConfirmPassword($0) }
            ),
            isFirstResponder: $isConfirmPasswordFieldFirstResponder,
            isError: viewStore.binding(
                get: { $0.password != $0.confirmPassword },
                send: .none
            ),
            title: LocalizedString.TextFieldTitle.confirmPassword,
            configuration: {
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.isSecureTextEntry = !isConfirmPasswordVisible
                $0.textContentType = .newPassword
                $0.placeholder = LocalizedString.TextFieldPlaceholder.confirmPassword
            },
            errorMessage: LocalizedString.TextFieldError.confirmPasswordNotMatch,
            onPaddingTapped: {
                self.isEmailFieldFirstResponder = false
                self.isPasswordFieldFirstResponder = false
                self.isConfirmPasswordFieldFirstResponder = true
            },
            onReturnTapped: {
                self.isEmailFieldFirstResponder = false
                self.isPasswordFieldFirstResponder = false
                self.isConfirmPasswordFieldFirstResponder = false
            },
            trailingAccessoryView: {
                PasswordEyeSymbolButton(isPasswordVisible: $isConfirmPasswordVisible)
            }
        )
    }
}

#if DEBUG
struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(
            store: .init(
                initialState: .init(),
                reducer: createAccountReducer,
                environment: .init()
            )
        )
    }
}
#endif
