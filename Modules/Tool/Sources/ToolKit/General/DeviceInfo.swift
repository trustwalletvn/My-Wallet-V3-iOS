// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol DeviceInfo {
    var systemVersion: String { get }
    var model: String { get }
    var uuidString: String { get }
}
