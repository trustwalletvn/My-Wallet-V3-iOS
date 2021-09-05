// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class AnalyticsEventRecorder: AnalyticsEventRecorderAPI {

    // MARK: - Properties

    private let analyticsServiceProviders: [AnalyticsServiceProviderAPI]

    // MARK: - Setup

    public init(analyticsServiceProviders: [AnalyticsServiceProviderAPI]) {
        self.analyticsServiceProviders = analyticsServiceProviders
    }

    public func record(event: AnalyticsEvent) {
        analyticsServiceProviders
            .filter { $0.isEventSupported(event) }
            .forEach {
                $0.trackEvent(title: event.name, parameters: event.params)
            }
    }
}
