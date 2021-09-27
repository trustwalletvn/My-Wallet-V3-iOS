// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import Localization
import SwiftUI
import UIComponentsKit

struct ResetPasswordView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.ResetPassword

    private enum Layout {
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let topPadding: CGFloat = 34
        static let bottomPadding: CGFloat = 34
        static let textFieldSpacing: CGFloat = 16
        static let messageFontSize: CGFloat = 12
        static let callOutMessageTopPadding: CGFloat = 10
        static let callOutMessageCornerRadius: CGFloat = 8
    }

    private let store: Store<ResetPasswordState, ResetPasswordAction>
    @ObservedObject private var viewStore: ViewStore<ResetPasswordState, ResetPasswordAction>

    @State private var isNewPasswordFieldFirstResponder: Bool = true
    @State private var isConfirmNewPasswordFieldFirstResponder: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmNewPasswordVisible: Bool = false

    init(store: Store<ResetPasswordState, ResetPasswordAction>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    var body: some View {
        VStack(alignment: .leading) {
            newPasswordField
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.newPasswordGroup)

            passwordInstruction
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.passwordInstructionText)

            PasswordStrengthIndicatorView(
                passwordStrength: viewStore.binding(
                    get: \.passwordStrength,
                    send: .none
                )
            )
            .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.passwordStrengthIndicatorGroup)

            confirmNewPasswordField
                .padding(.top, Layout.textFieldSpacing)
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.confirmNewPasswordGroup)

            securityCallOut
                .padding(.top, Layout.callOutMessageTopPadding)
                .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.securityCallOutGroup)

            Spacer()

            PrimaryButton(title: LocalizedString.Button.resetPassword) {
                // TODO: reset password operation
            }
            .disabled(viewStore.newPassword.isEmpty || viewStore.newPassword != viewStore.confirmNewPassword ||
                viewStore.passwordStrength != .strong)
            .accessibility(identifier: AccessibilityIdentifiers.ResetPasswordScreen.resetPasswordButton)
        }
        .navigationBarTitle(LocalizedString.navigationTitle, displayMode: .inline)
        .hideBackButtonTitle()
        .padding(
            EdgeInsets(
                top: Layout.topPadding,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
        .onDisappear {
            viewStore.send(.didDisappear)
        }
    }

    private var newPasswordField: some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: \.newPassword,
                send: { .didChangeNewPassword($0) }
            ),
            isFirstResponder: $isNewPasswordFieldFirstResponder,
            isError: .constant(false),
            title: LocalizedString.TextFieldTitle.newPassword,
            configuration: {
                $0.isSecureTextEntry = !isPasswordVisible
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.placeholder = LocalizedString.TextFieldPlaceholder.newPassword
                $0.textContentType = .newPassword
            },
            onPaddingTapped: {
                isNewPasswordFieldFirstResponder = true
                isConfirmNewPasswordFieldFirstResponder = false
            },
            onReturnTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = true
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

    private var confirmNewPasswordField: some View {
        FormTextFieldGroup(
            text: viewStore.binding(
                get: \.confirmNewPassword,
                send: { .didChangeConfirmNewPassword($0) }
            ),
            isFirstResponder: $isConfirmNewPasswordFieldFirstResponder,
            isError: viewStore.binding(
                get: { $0.newPassword != $0.confirmNewPassword },
                send: .none
            ),
            title: LocalizedString.TextFieldTitle.confirmNewPassword,
            configuration: {
                $0.isSecureTextEntry = !isConfirmNewPasswordVisible
                $0.autocorrectionType = .no
                $0.autocapitalizationType = .none
                $0.placeholder = LocalizedString.TextFieldPlaceholder.confirmNewPassword
                $0.textContentType = .newPassword
            },
            errorMessage: LocalizedString.confirmPasswordNotMatch,
            onPaddingTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = true
            },
            onReturnTapped: {
                isNewPasswordFieldFirstResponder = false
                isConfirmNewPasswordFieldFirstResponder = false
            },
            trailingAccessoryView: {
                PasswordEyeSymbolButton(isPasswordVisible: $isConfirmNewPasswordVisible)
            }
        )
    }

    private var securityCallOut: some View {
        HStack {
            Text(LocalizedString.securityCallOut + " ")
                .font(Font(weight: .medium, size: Layout.messageFontSize))
                .foregroundColor(.textSubheading) +
                Text(LocalizedString.Button.learnMore)
                .font(Font(weight: .medium, size: Layout.messageFontSize))
                .foregroundColor(Color.buttonPrimaryBackground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(
            RoundedRectangle(cornerRadius: Layout.callOutMessageCornerRadius)
                .fill(Color.textCallOutBackground)
        )
        .onTapGesture {
            viewStore.send(.open(urlContent: .identifyVerificationOverview))
        }
    }
}

#if DEBUG
struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(
            store: .init(
                initialState: .init(),
                reducer: resetPasswordReducer,
                environment: .init(
                    mainQueue: .main
                )
            )
        )
    }
}
#endif
