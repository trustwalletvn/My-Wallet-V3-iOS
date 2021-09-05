// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension AccountPickerRow {

    public struct LinkedBankAccountModel: Equatable {

        public init(
            title: String,
            description: String,
            badgeImage: Image? = nil,
            multiBadgeView: Image? = nil
        ) {
            self.title = title
            self.description = description
            self.badgeImage = badgeImage
            self.multiBadgeView = multiBadgeView
        }

        var title: String
        var description: String
        var badgeImage: Image?
        var multiBadgeView: Image?
    }
}
