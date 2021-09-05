// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol AppSettingsAPI: AnyObject {
    var sharedKey: String? { get set }
    var guid: String? { get set }
}

extension AppSettingsAPI {
    /// Streams the GUID if exists
    public var guid: Single<String?> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.guid)
        }
    }

    /// Streams the shared key if exists
    public var sharedKey: Single<String?> {
        Single.deferred { [weak self] in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return .just(self.sharedKey)
        }
    }
}
