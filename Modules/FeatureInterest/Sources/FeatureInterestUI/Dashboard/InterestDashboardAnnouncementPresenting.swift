// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

public protocol InterestDashboardAnnouncementPresenting: AnyObject {
    var cellArrangement: [InterestAnnouncementCellType] { get }
    var cellCount: Int { get }
}
