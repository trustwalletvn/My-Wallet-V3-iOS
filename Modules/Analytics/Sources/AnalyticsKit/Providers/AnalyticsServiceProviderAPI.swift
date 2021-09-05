// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AnalyticsServiceProviderAPI {

    func trackEvent(title: String)

    func trackEvent(title: String, parameters: [String: Any]?)

    var supportedEventTypes: [AnalyticsEventType] { get }
}

extension AnalyticsServiceProviderAPI {

    public func trackEvent(title: String) {
        trackEvent(title: title, parameters: nil)
    }

    func isEventSupported(_ event: AnalyticsEvent) -> Bool {
        supportedEventTypes.contains(event.type)
    }
}
