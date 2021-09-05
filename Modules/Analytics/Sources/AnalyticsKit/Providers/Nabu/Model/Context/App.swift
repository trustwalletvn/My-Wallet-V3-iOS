// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct App: Encodable {
    let name: String? = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    let version: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let build: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    let namespace: String? = Bundle.main.bundleIdentifier
}
