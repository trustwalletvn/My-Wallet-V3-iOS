// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Mockingbird
import XCTest

@testable import AnalyticsKit

final class AnalyticsEventRecorderTests: XCTestCase {

    let analyticsProviderMock = mock(AnalyticsServiceProviderAPI.self)
    let eventMock = mock(AnalyticsEvent.self)

    var analyticsEventRecorder: AnalyticsEventRecorder?

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsEventRecorder = AnalyticsEventRecorder(analyticsServiceProviders: [analyticsProviderMock])
        given(eventMock.getType()) ~> .nabu
        given(eventMock.getName()) ~> "name"
    }

    override func tearDownWithError() throws {
        analyticsEventRecorder = nil
        reset(eventMock)
        try super.tearDownWithError()
    }

    func test_analyticsEventRecorder_callingTrackEventInAnalyticsProvider_onTypeMatch() throws {
        given(analyticsProviderMock.getSupportedEventTypes()) ~> [.nabu]

        analyticsEventRecorder?.record(event: eventMock)

        verify(analyticsProviderMock.trackEvent(title: "name", parameters: any())).wasCalled(exactly(1))
    }

    func test_analyticsEventRecorder_NotCallingAnalyticsProvider_onTypeMismatch() throws {
        given(analyticsProviderMock.getSupportedEventTypes()) ~> [.firebase]

        analyticsEventRecorder?.record(event: eventMock)

        verify(analyticsProviderMock.trackEvent(title: "name", parameters: any())).wasNeverCalled()
    }

    func test_analyticsEventRecorder_callingAnalyticsProvidersForEachEvent_onTypeMatch() throws {
        given(analyticsProviderMock.getSupportedEventTypes()) ~> [.nabu]

        analyticsEventRecorder?.record(events: [eventMock, eventMock])

        verify(analyticsProviderMock.trackEvent(title: "name", parameters: any())).wasCalled(2)
    }
}
