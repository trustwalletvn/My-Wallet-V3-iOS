// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

public enum InterestAnnouncementCellType {
    case item(LineItemCellPresenting)
    case footer(FooterTableViewCellPresenter)
    case announcement(AnnouncementCardViewModel)
    case numberedItem(BadgeNumberedItemViewModel)
    case buttons([ButtonViewModel])
}
