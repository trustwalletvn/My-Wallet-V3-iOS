// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension AccountPickerRow {

    public struct SingleAccountModel: Equatable {

        init(
            title: String,
            description: String,
            pending: String,
            fiatBalance: String,
            cryptoBalance: String,
            badgeImage: Image? = nil,
            thumbSideImage: Image? = nil,
            multiBadge: Image? = nil
        ) {
            self.title = title
            self.description = description
            self.pending = pending
            self.fiatBalance = fiatBalance
            self.cryptoBalance = cryptoBalance
            self.badgeImage = badgeImage
            self.thumbSideImage = thumbSideImage
            self.multiBadge = multiBadge
        }

        var title: String
        var description: String
        var pending: String
        var fiatBalance: String
        var cryptoBalance: String
        var badgeImage: Image?
        var thumbSideImage: Image?
        var multiBadge: Image?
    }
}
