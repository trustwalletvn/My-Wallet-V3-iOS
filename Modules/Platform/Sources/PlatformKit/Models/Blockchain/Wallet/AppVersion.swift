// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct AppVersion {
    public let major: Int
    public let minor: Int
    public let patch: Int
}

extension AppVersion {
    public init?(string: String) {
        let components = string.components(separatedBy: ".")
        guard let majorStr = components.safe(0),
              let minorStr = components.safe(1),
              let patchStr = components.safe(2)
        else {
            return nil
        }
        guard let major = Int(majorStr),
              let minor = Int(minorStr),
              let patch = Int(patchStr)
        else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension AppVersion: Comparable, Equatable {

    public static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        return lhs.patch < rhs.patch
    }

    public static func <= (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs == rhs || lhs < rhs
    }

    public static func >= (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs == rhs || lhs > rhs
    }

    public static func > (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major > rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor > rhs.minor
        }
        return lhs.patch > rhs.patch
    }

    public static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}

extension Array {
    fileprivate func safe(_ index: Int) -> Element? {
        guard (0..<count).contains(index) else { return nil }
        return self[index]
    }
}
