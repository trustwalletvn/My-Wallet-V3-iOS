// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

struct Device: Encodable {
    let id: String?
    let manufacturer: String
    let model: String
    let name: String
    let type: String

    init(device: UIDevice = UIDevice.current) {
        id = device.identifierForVendor?.uuidString
        manufacturer = "Apple"
        model = device.model
        name = device.name
        type = "ios"
    }
}
