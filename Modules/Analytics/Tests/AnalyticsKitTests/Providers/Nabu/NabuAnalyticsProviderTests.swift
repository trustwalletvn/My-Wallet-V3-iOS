// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Mockingbird
import XCTest

@testable import AnalyticsKit

final class NabuAnalyticsProviderTests: XCTestCase {
    var nabuAnalyticsProvider: NabuAnalyticsProvider?

    let testQueue = DispatchQueue(label: "Test")
    let notificationCenter = NotificationCenter()

    let fileCacheMock = mock(FileCacheAPI.self)
    let nabuAnalyticsEventsRepositoryMock = mock(NabuAnalyticsEventsRepositoryAPI.self)
    let contextProviderMock = mock(ContextProviderAPI.self)

    override func setUpWithError() throws {
        try super.setUpWithError()

        given(contextProviderMock.getAnonymousId()) ~> "anonymousId"
        given(contextProviderMock.getContext()).willReturn(
            Context(
                app: App(),
                device: Device(),
                os: OperatingSystem(),
                locale: "en-US",
                screen: Screen(),
                timezone: "GMT"
            )
        )
        given(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self)))
            ~> Empty().eraseToAnyPublisher()
        given(fileCacheMock.read()) ~> [Event(title: "Test", properties: nil)]
    }

    override func tearDownWithError() throws {
        reset(contextProviderMock)
        reset(nabuAnalyticsEventsRepositoryMock)
        reset(fileCacheMock)
        nabuAnalyticsProvider = nil

        try super.tearDownWithError()
    }

    func test_nabuAnalyticsProvider_sendsWhenBatchIsFull() {
        let batchSize = 5
        nabuAnalyticsProvider = createNabuAnalyticsProvider(batchSize: batchSize)

        for _ in 1...batchSize {
            nabuAnalyticsProvider?.trackEvent(title: "Test", parameters: nil)
        }

        let expectation = eventually {
            verify(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self))).wasCalled(exactly(1))
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_nabuAnalyticsProvider_sendsAfterUpdateTimeInterval() {
        nabuAnalyticsProvider = createNabuAnalyticsProvider(updateTimeInterval: 0.1)

        nabuAnalyticsProvider?.trackEvent(title: "Test", parameters: nil)

        let expectation = eventually {
            verify(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self))).wasCalled(exactly(1))
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func test_nabuAnalyticsProvider_sendsAfterGoingIntoBackground() {
        nabuAnalyticsProvider = createNabuAnalyticsProvider()

        nabuAnalyticsProvider?.trackEvent(title: "Test", parameters: nil)
        testQueue.sync {
            notificationCenter.post(name: UIApplication.willResignActiveNotification, object: nil)
        }

        let expectation = eventually {
            verify(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self))).wasCalled(exactly(1))
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_nabuAnalyticsProvider_readsCacheAndSendsAfterGoingIntoForeground() {
        nabuAnalyticsProvider = createNabuAnalyticsProvider()

        nabuAnalyticsProvider?.trackEvent(title: "Test", parameters: nil)
        testQueue.sync {
            notificationCenter.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        }

        let expectation = eventually {
            verify(fileCacheMock.read()).wasCalled(1)
            verify(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self))).wasCalled(1)
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_nabuAnalyticsProvider_savesToCacheOnServerError() {
        given(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self)))
            ~> Fail<Never, URLError>(error: URLError(.init(rawValue: 500))).eraseToAnyPublisher()
        nabuAnalyticsProvider = createNabuAnalyticsProvider(batchSize: 1)

        nabuAnalyticsProvider?.trackEvent(title: "Test", parameters: nil)

        let expectation = eventually {
            verify(fileCacheMock.save(events: any([Event].self))).wasCalled(exactly(1))
            verify(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self))).wasCalled(exactly(1))
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func test_nabuAnalyticsProvider_backoffAfterServerError() {
        given(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self)))
            ~> Fail<Never, URLError>(error: URLError(.init(rawValue: 500))).eraseToAnyPublisher()
        nabuAnalyticsProvider = createNabuAnalyticsProvider(batchSize: 1)

        nabuAnalyticsProvider?.trackEvent(title: "Test-1", parameters: nil)
        nabuAnalyticsProvider?.trackEvent(title: "Test-2", parameters: nil)

        let expectation = eventually {
            verify(fileCacheMock.save(events: any([Event].self))).wasCalled(exactly(2))
            verify(nabuAnalyticsEventsRepositoryMock.publish(events: any(EventsWrapper.self))).wasCalled(exactly(1))
        }
        wait(for: [expectation], timeout: 5.0)
    }

    fileprivate func createNabuAnalyticsProvider(
        batchSize: Int = 20,
        updateTimeInterval: TimeInterval = 30
    ) -> NabuAnalyticsProvider {
        NabuAnalyticsProvider(
            platform: .wallet,
            batchSize: batchSize,
            updateTimeInterval: updateTimeInterval,
            fileCache: fileCacheMock,
            eventsRepository: nabuAnalyticsEventsRepositoryMock,
            contextProvider: contextProviderMock,
            notificationCenter: notificationCenter,
            queue: testQueue
        )
    }
}
