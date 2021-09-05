// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// Protocol for a view that performs an async function.
public protocol LoadingView: AnyObject {
    func showLoadingIndicator()

    func hideLoadingIndicator()

    func showErrorMessage(_ message: String)
}
