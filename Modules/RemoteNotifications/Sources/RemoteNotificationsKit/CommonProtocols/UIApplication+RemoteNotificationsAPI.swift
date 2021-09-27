// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

protocol UIApplicationRemoteNotificationsAPI: AnyObject {
    func registerForRemoteNotifications()
}

extension UIApplication: UIApplicationRemoteNotificationsAPI {}
