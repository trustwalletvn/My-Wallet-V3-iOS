// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG
import Foundation

/// An empty implementation of `AnalyticsEventRecorderAPI` to support Unit Tests, SwiftUI previews, etc.
public final class NoOpAnalyticsRecorder: AnalyticsEventRecorderAPI {

    public init() {}

    public func record(event: AnalyticsEvent) {
        // no-op
    }
}
#endif
