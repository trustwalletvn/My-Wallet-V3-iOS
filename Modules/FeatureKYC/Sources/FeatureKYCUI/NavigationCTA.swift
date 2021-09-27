// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

enum NavigationCTA {
    case dismiss
    case help
    case none
}

extension NavigationCTA {
    var image: UIImage? {
        switch self {
        case .dismiss:
            return UIImage(named: "close", in: .featureKYCUI, compatibleWith: nil)
        case .help:
            return UIImage(named: "ios_icon_more", in: .featureKYCUI, compatibleWith: nil)
        case .none:
            return nil
        }
    }

    var visibility: Visibility {
        switch self {
        case .dismiss:
            return .visible
        case .help:
            return .visible
        case .none:
            return .hidden
        }
    }
}
