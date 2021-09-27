// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol TransactionConfirmationModelable: Hashable {
    var type: TransactionConfirmation.Kind { get }
    var formatted: (title: String, subtitle: String)? { get }
}

extension TransactionConfirmationModelable {

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}
