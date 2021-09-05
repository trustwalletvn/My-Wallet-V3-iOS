// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

struct OperatingSystem: Encodable {
    let name: String
    let version: String

    init(device: UIDevice = UIDevice.current) {
        name = device.systemName
        version = device.systemVersion
    }
}
