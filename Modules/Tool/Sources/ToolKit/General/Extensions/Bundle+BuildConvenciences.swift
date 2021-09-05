// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Bundle {

    /// Provides the builder number and version using this format:
    /// - Production builds: v1.0.0 (1)
    /// - Internal builds: v1.0.0 (commit hash)
    /// - Returns: A `String` representing the build number
    public static func versionAndBuildNumber() -> String {
        var hash = ""
        if let info = Bundle.main.infoDictionary {
            hash = (info["COMMIT_HASH"] as? String ?? "")
        }
        var title = "v\(Bundle.applicationVersion ?? "")"
        #if INTERNAL_BUILD
        title = "\(title) (\(hash))"
        #else
        title = "\(title) (\(applicationBuildVersion ?? ""))"
        #endif
        return title
    }

    /// The application version. Equivalent to CFBundleShortVersionString.
    public static var applicationVersion: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let version = infoDictionary["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return version
    }

    /// The build version of the application. Equivalent to CFBundleVersion.
    public static var applicationBuildVersion: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let buildVersion = infoDictionary["CFBundleVersion"] as? String else {
            return nil
        }
        return buildVersion
    }

    /// The name of the application. Equivalent to CFBundleDisplayName.
    public static var applicationName: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let appName = infoDictionary["CFBundleDisplayName"] as? String else {
            return nil
        }
        return appName
    }
}
