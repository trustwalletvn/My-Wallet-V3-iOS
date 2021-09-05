// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Types adopting `WalletSuccessCallback` should provide a way to call a success method
@objc public protocol WalletSuccessCallback {
    func success(string: String)
}

/// Types adopting `WalletDismissCallback` should provide a way to call a dissmis method
@objc public protocol WalletDismissCallback {
    func dismiss()
}
