// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore

public protocol JSContextProviderAPI: AnyObject {
    var jsContext: JSContext { get }

    func fetchJSContext() -> JSContext
}

extension JSContextProviderAPI {
    public var jsContext: JSContext {
        fetchJSContext()
    }
}
