// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import JavaScriptCore
import ToolKit

public class MockContextProvider: JSContextProviderAPI {
    public var underlyingContext: JSContext!

    public func fetchJSContext() -> JSContext {
        underlyingContext
    }

    public init(underlyingContext: JSContext? = nil) {
        self.underlyingContext = underlyingContext
    }
}
