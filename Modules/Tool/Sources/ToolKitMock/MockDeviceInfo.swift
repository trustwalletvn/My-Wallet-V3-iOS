// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import ToolKit

struct MockDeviceInfo: DeviceInfo {
    let systemVersion: String
    let model: String
    let uuidString: String
}
