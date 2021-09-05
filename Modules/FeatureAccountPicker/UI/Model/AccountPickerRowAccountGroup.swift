// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension AccountPickerRow {

    public struct AccountGroupModel: Equatable {

        public init(
            title: String,
            description: String,
            fiatBalance: String,
            currencyCode: String,
            badgeImage: Image? = nil
        ) {
            self.title = title
            self.description = description
            self.fiatBalance = fiatBalance
            self.currencyCode = currencyCode
            self.badgeImage = badgeImage
        }

        var title: String
        var description: String
        var fiatBalance: String
        var currencyCode: String
        var badgeImage: Image?
    }
}
