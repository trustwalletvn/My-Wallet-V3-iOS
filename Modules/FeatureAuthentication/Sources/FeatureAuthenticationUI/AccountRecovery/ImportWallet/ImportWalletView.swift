// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import SwiftUI
import UIComponentsKit

struct ImportWalletView: View {

    private typealias LocalizedString = LocalizationConstants.FeatureAuthentication.ImportWallet

    private enum Layout {
        static let imageSideLength: CGFloat = 72

        static let messageFontSize: CGFloat = 16
        static let messageLineSpacing: CGFloat = 4

        static let bottomPadding: CGFloat = 34
        static let leadingPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 24
        static let titleTopPadding: CGFloat = 16
        static let buttonBottomPadding: CGFloat = 10
    }

    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image.CircleIcon.importWallet
                    .frame(width: Layout.imageSideLength, height: Layout.imageSideLength)
                    .accessibility(identifier: AccessibilityIdentifiers.ImportWalletScreen.importWalletImage)

                Text(LocalizedString.importWalletTitle)
                    .textStyle(.title)
                    .padding(.top, Layout.titleTopPadding)
                    .accessibility(identifier: AccessibilityIdentifiers.ImportWalletScreen.importWalletTitleText)

                Text(LocalizedString.importWalletMessage)
                    .font(Font(weight: .medium, size: Layout.messageFontSize))
                    .foregroundColor(.textSubheading)
                    .lineSpacing(Layout.messageLineSpacing)
                    .accessibility(identifier: AccessibilityIdentifiers.ImportWalletScreen.importWalletMessageText)
                Spacer()
            }
            VStack {
                PrimaryButton(title: LocalizedString.Button.importWallet) {
                    // TODO: import wallet
                }
                .padding(.bottom, Layout.buttonBottomPadding)
                SecondaryButton(title: LocalizedString.Button.goBack) {
                    // TODO: go back
                }
            }
        }
        .multilineTextAlignment(.center)
        .navigationBarTitleDisplayMode(.inline)
        .hideBackButtonTitle()
        .padding(
            EdgeInsets(
                top: 0,
                leading: Layout.leadingPadding,
                bottom: Layout.bottomPadding,
                trailing: Layout.trailingPadding
            )
        )
    }
}

#if DEBUG
struct ImportWalletView_Previews: PreviewProvider {
    static var previews: some View {
        ImportWalletView()
    }
}
#endif
