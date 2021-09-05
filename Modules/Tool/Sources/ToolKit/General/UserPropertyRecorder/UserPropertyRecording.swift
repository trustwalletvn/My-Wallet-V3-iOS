// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// This protocol enables user property recording, whether it can be persisted into disk,
/// keychain, user defaults, remote configuration on a third party service,
/// backend or even being cached to memory.
public protocol UserPropertyRecording: AnyObject {

    /// Records the user identifier
    func record(id: String)

    /// Records a standard user property
    func record(_ property: StandardUserProperty)

    /// Records a hashed user property
    func record(_ property: HashedUserProperty)
}
