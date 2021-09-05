// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import Foundation
import UIKit

public final class NabuAnalyticsProvider: AnalyticsServiceProviderAPI {

    public var supportedEventTypes: [AnalyticsEventType] = [.nabu]

    private let platform: Platform
    private let batchSize: Int
    private let updateTimeInterval: TimeInterval
    private var lastFailureTimeInterval: TimeInterval = 0
    private var consequentFailureCount: Double = 0
    private var backoffDelay: Double {
        let delay = Int(pow(2, consequentFailureCount) * 10).subtractingReportingOverflow(1)
        return Double(delay.overflow ? .max : delay.partialValue + 1)
    }

    private let fileCache: FileCacheAPI
    private let eventsRepository: NabuAnalyticsEventsRepositoryAPI
    private let contextProvider: ContextProviderAPI
    private let notificationCenter: NotificationCenter

    private let queue: DispatchQueue

    private var cancellables = Set<AnyCancellable>()

    @Published private var events = [Event]()

    public convenience init(
        platform: Platform,
        basePath: String,
        userAgent: String,
        tokenRepository: TokenRepositoryAPI,
        guidProvider: GuidRepositoryAPI
    ) {
        let client = APIClient(basePath: basePath, userAgent: userAgent)
        let eventsRepository = NabuAnalyticsEventsRepository(client: client, tokenRepository: tokenRepository)
        let contextProvider = ContextProvider(guidProvider: guidProvider)
        self.init(
            platform: platform,
            eventsRepository: eventsRepository,
            contextProvider: contextProvider
        )
    }

    init(
        platform: Platform,
        batchSize: Int = 20,
        updateTimeInterval: TimeInterval = 30,
        fileCache: FileCacheAPI = FileCache(),
        eventsRepository: NabuAnalyticsEventsRepositoryAPI,
        contextProvider: ContextProviderAPI,
        notificationCenter: NotificationCenter = .default,
        queue: DispatchQueue = .init(label: "AnalyticsKit", qos: .background)
    ) {
        self.platform = platform
        self.batchSize = batchSize
        self.updateTimeInterval = updateTimeInterval
        self.fileCache = fileCache
        self.eventsRepository = eventsRepository
        self.contextProvider = contextProvider
        self.notificationCenter = notificationCenter
        self.queue = queue

        setupBatching()
    }

    private func setupBatching() {
        queue.sync { [weak self] in
            guard let self = self else { return }

            // Sending triggers

            let updateRateTimer = Timer
                .publish(every: self.updateTimeInterval, on: .current, in: .default)
                .autoconnect()
                .withLatestFrom(self.$events)

            let batchFull = self.$events
                .filter { $0.count >= self.batchSize }

            let enteredBackground = self.notificationCenter
                .publisher(for: UIApplication.willResignActiveNotification)
                .withLatestFrom(self.$events)

            updateRateTimer
                .merge(with: batchFull)
                .merge(with: enteredBackground)
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .subscribe(on: queue)
                .receive(on: queue)
                .sink(receiveValue: self.send)
                .store(in: &self.cancellables)

            // Reading cache

            self.notificationCenter
                .publisher(for: UIApplication.didEnterBackgroundNotification)
                .receive(on: self.queue)
                .compactMap { _ in self.fileCache.read() }
                .filter { !$0.isEmpty }
                .removeDuplicates()
                .subscribe(on: queue)
                .receive(on: queue)
                .sink(receiveValue: self.send)
                .store(in: &self.cancellables)
        }
    }

    public func trackEvent(title: String, parameters: [String: Any]?) {
        queue.sync { [weak self] in
            self?.events.append(Event(title: title, properties: parameters))
        }
    }

    private func send(events: [Event]) {
        self.events = self.events.filter { !events.contains($0) }

        // This is simple backoff logic:
        // If time elapsed between now and last failure is greater than backoffDelay - try sending,
        // Otherwise - save to file cache and don't send the request.
        if Date().timeIntervalSince1970 - lastFailureTimeInterval <= backoffDelay {
            fileCache.save(events: events)
            return
        }

        let eventsWrapper = EventsWrapper(contextProvider: contextProvider, events: events, platform: platform)
        eventsRepository.publish(events: eventsWrapper)
            .subscribe(on: queue)
            .receive(on: queue)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    if Constants.allowedErrorCodes.contains(error.errorCode)
                        || error.networkUnavailableReason != nil
                    {
                        self.fileCache.save(events: events)
                    }
                    self.consequentFailureCount += 1
                    self.lastFailureTimeInterval = Date().timeIntervalSince1970
                case .finished:
                    self.consequentFailureCount = 0
                    self.lastFailureTimeInterval = 0
                }
            } receiveValue: { _ in
                // NOOP
            }
            .store(in: &cancellables)
    }

    private enum Constants {
        static let allowedErrorCodes = 500...599
    }
}
