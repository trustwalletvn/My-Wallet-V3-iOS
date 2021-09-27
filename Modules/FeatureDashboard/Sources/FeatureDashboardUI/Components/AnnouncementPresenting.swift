// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformUIKit
import RxCocoa

public protocol AnnouncementPresenting {

    var announcement: Driver<AnnouncementDisplayAction> { get }

    func refresh()
}
