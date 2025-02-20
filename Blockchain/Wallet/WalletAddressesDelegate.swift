// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Protocol definition for a delegate for addresses-related wallet callbacks
@objc protocol WalletAddressesDelegate: AnyObject {
    /// Method invoked when finding a null account or address when checking if archived
    func returnToAddressesScreen()
}
