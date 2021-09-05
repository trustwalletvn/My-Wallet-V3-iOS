// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

struct Screen: Encodable {
    let width = Double(UIScreen.main.bounds.width)
    let height = Double(UIScreen.main.bounds.height)
    let density = Double(UIScreen.main.scale)
}
