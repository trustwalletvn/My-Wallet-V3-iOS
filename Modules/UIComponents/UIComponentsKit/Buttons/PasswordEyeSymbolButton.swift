// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

public struct PasswordEyeSymbolButton: View {

    @Binding private var isPasswordVisible: Bool

    public init(isPasswordVisible: Binding<Bool>) {
        _isPasswordVisible = isPasswordVisible
    }

    public var body: some View {
        Button(
            action: { isPasswordVisible.toggle() },
            label: {
                Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundColor(Color.secureFieldEyeSymbol)
            }
        )
    }
}
