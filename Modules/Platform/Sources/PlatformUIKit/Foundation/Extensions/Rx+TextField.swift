// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
    /// Bindable for `isSecureTextEntry` property
    public var isSecureTextEntry: Binder<Bool> {
        Binder(base) { textField, isSecureTextEntry in
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }

    /// Bindable for `textContentType` property
    public var contentType: Binder<UITextContentType?> {
        Binder(base) { textField, contentType in
            textField.textContentType = contentType
        }
    }

    /// Bindable for `keyboardType` property
    public var keyboardType: Binder<UIKeyboardType> {
        Binder(base) { textField, keyboardType in
            textField.keyboardType = keyboardType
        }
    }

    /// Bindable for `returnKeyType` property
    public var returnKeyType: Binder<UIReturnKeyType> {
        Binder(base) { textField, returnKeyType in
            textField.returnKeyType = returnKeyType
        }
    }

    /// Bindable for `autocapitalizationType` property
    public var autocapitalizationType: Binder<UITextAutocapitalizationType> {
        Binder(base) { textField, autocapitalizationType in
            textField.autocapitalizationType = autocapitalizationType
        }
    }

    /// Bindable for `placeholderAttributedText` property
    public var placeholderAttributedText: Binder<NSAttributedString?> {
        Binder(base) { textField, placeholder in
            textField.attributedPlaceholder = placeholder
        }
    }

    /// Bindable for `textColor` property
    public var textColor: Binder<UIColor> {
        Binder(base) { textField, textColor in
            textField.textColor = textColor
        }
    }
}
