// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct PulseViewModel {
    public let container: UIView
    public let onSelection: () -> Void

    public init(container: UIView, onSelection: @escaping () -> Void) {
        self.container = container
        self.onSelection = onSelection
    }
}
