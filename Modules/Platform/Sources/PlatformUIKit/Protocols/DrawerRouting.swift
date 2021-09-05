// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol DrawerRouting: AnyObject {
    /// Closes or open the side menu, depending on its current state
    func toggleSideMenu()

    /// Closes the side menu
    func closeSideMenu()
}
