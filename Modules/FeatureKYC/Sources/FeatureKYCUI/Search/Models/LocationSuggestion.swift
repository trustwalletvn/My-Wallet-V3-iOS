// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct LocationSuggestion: SearchSelection {

    typealias HighlightRanges = [NSRange]

    let title: String
    let subtitle: String
    let titleHighlights: HighlightRanges
    let subtitleHighlights: HighlightRanges
}
